defmodule WhatsappCloneWeb.ConversationController do
  use WhatsappCloneWeb, :controller

  alias WhatsappClone.{Repo, Conversations, ConversationMember, Conversation, Message}
  import Ecto.Query

  action_fallback WhatsappCloneWeb.FallbackController

  @doc """
  GET /api/users/:id/conversations
  Lists all conversations for user `id`. Returns each conversation plus its last message.
  """
  # def index(conn, %{"id" => user_id}) do
  #   conversations = Conversations.list_user_conversations(user_id)
  #   render(conn, WhatsappCloneWeb.ConversationView, "index.json", conversations: conversations)
  # end


  @doc """
  POST /api/conversations
  Body params: %{
    "is_group" => true | false,
    "group_name" => "Optional if is_group",
    "group_avatar_url" => "...",
    "created_by" => <user_id>,
    "members" => [<user_id>, <user_id>, ...]
  }
  Returns the newly created conversation.
  """

def create(conn, params) do
  case create_conversation(params) do
    {:ok, convo} ->
      render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)

    {:error, changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: render_changeset_errors(changeset)})
  end
end

@doc """
PATCH /api/conversations/:id/add_member
Body params: %{"user_id" => <user_to_add_id>}

Only admins of the conversation can add new members.
"""
def add_member(conn, %{"id" => convo_id, "user_id" => new_user_id}) do
  current_user_id = conn.assigns[:user_id]

  is_admin? =
    Repo.exists?(
      from cm in ConversationMember,
      where: cm.conversation_id == ^convo_id and cm.user_id == ^current_user_id and cm.is_admin == true
    )

  if is_admin? do
    # Check if user is already a member to avoid duplicates
    already_member? =
      Repo.exists?(
        from cm in ConversationMember,
        where: cm.conversation_id == ^convo_id and cm.user_id == ^new_user_id
      )

    if already_member? do
      conn
      |> put_status(:conflict)
      |> json(%{error: "User is already a member"})
    else
      # Insert new member
      changeset =
        %ConversationMember{}
        |> ConversationMember.changeset(%{
          conversation_id: convo_id,
          user_id: new_user_id,
          joined_at: DateTime.utc_now(),
          is_admin: false
        })

        case Repo.insert(changeset) do
          {:ok, _member} ->
            convo =
              Conversations.get_conversation!(convo_id)
              |> Repo.preload([
                :messages,
                conversation_members: [:user]   # ✅ No trailing comma here
              ])

            render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: render_changeset_errors(changeset)})
        end

    end
  else
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Only admins can add members"})
  end
end
def remove_member(conn, %{"id" => convo_id, "user_id" => user_id_to_remove}) do
  current_user_id = conn.assigns[:user_id]

  is_admin? =
    Repo.exists?(
      from cm in ConversationMember,
      where:
        cm.conversation_id == ^convo_id and
        cm.user_id == ^current_user_id and
        cm.is_admin == true
    )

  if is_admin? do
    case Repo.get_by(ConversationMember, conversation_id: convo_id, user_id: user_id_to_remove) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found in the conversation"})

      member ->
        # Prevent removing the group creator or self (optional)
        if member.user_id == current_user_id do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "You can't remove yourself from the group"})
        else
          case Repo.delete(member) do
            {:ok, _} ->
              convo =
                Conversations.get_conversation!(convo_id)
                |> Repo.preload(conversation_members: [:user], messages: [])
              render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{errors: render_changeset_errors(changeset)})
          end
        end
    end
  else
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Only admins can remove members"})
  end
end

def create_conversation(attrs) do
  members = Map.get(attrs, "members", [])
  created_by = Map.get(attrs, "created_by")

  # Add creator to members if not present
  members =
    if created_by in members do
      members
    else
      [created_by | members]
    end

  %Conversation{}
  |> Conversation.changeset(attrs)
  |> Repo.insert()
  |> case do
    {:ok, convo} ->
      member_records = Enum.map(members, fn user_id ->
        %{
          conversation_id: convo.id,
          user_id: user_id,
          joined_at: DateTime.utc_now(),
          is_admin: user_id == created_by
        }
      end)

      Repo.insert_all(ConversationMember, member_records)
      {:ok, Repo.preload(convo, [:conversation_members, :messages])}

    error -> error
  end
end

  @doc """
  GET /api/conversations?
  (In your router, this route is used to list conversations for current user.)
  We assume `conn.assigns.user_id` is set by an authentication plug.
  """
  def list_for_current_user(conn, _params) do
    user_id = conn.assigns[:user_id]
    conversations = Conversations.list_user_conversations(user_id)

    render(conn, WhatsappCloneWeb.ConversationView, "index.json", conversations: conversations)
  end


  @doc """
  PATCH /api/conversations/:id
  Updates a conversation’s metadata (e.g., changing group name or avatar).
  Body params: %{"group_name" => "...", "group_avatar_url" => "..."}
  """
  def update(conn, %{"id" => convo_id} = params) do
    user_id = conn.assigns[:user_id]

    # Check if user is admin of the conversation
    is_admin =
      Repo.exists?(
        from cm in ConversationMember,
        where: cm.conversation_id == ^convo_id and cm.user_id == ^user_id and cm.is_admin == true
      )

    if is_admin do
      attrs = Map.drop(params, ["id"])
      case Conversations.update_conversation(convo_id, attrs) do
        {:ok, convo} ->
          convo = Repo.preload(convo, [:conversation_members, :messages])
          render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: render_changeset_errors(changeset)})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Only admins can update the conversation"})
    end
  end

  @doc """
DELETE /api/conversations/:id
Deletes a conversation if the current user is admin.
"""
def delete(conn, %{"id" => convo_id}) do
  user_id = conn.assigns[:user_id]

  is_admin =
    Repo.exists?(
      from cm in ConversationMember,
      where: cm.conversation_id == ^convo_id and cm.user_id == ^user_id and cm.is_admin == true
    )

  if is_admin do
    case Conversations.get_conversation(convo_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Conversation not found"})

      convo ->
        case Conversations.delete_conversation(convo) do
          {:ok, _struct} ->
            send_resp(conn, :no_content, "")

          {:error, _reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to delete conversation"})
        end
    end
  else
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Only admins can delete the conversation"})
  end
end

  @doc """
PATCH /api/conversations/:id/admins
Body params: %{
  "admins_to_add" => [<user_id>, ...],       # optional
  "admins_to_remove" => [<user_id>, ...]    # optional
}
Only current admins can update the admins.
"""
def update_admins(conn, %{"id" => convo_id} = params) do
  user_id = conn.assigns[:user_id]

  is_admin =
    Repo.exists?(
      from cm in ConversationMember,
      where: cm.conversation_id == ^convo_id and cm.user_id == ^user_id and cm.is_admin == true
    )

  if is_admin do
    admins_to_add = Map.get(params, "admins_to_add", [])
    admins_to_remove = Map.get(params, "admins_to_remove", [])

    # Add admin flag for given user_ids
    from(cm in ConversationMember,
      where: cm.conversation_id == ^convo_id and cm.user_id in ^admins_to_add
    )
    |> Repo.update_all(set: [is_admin: true])

    from(cm in ConversationMember,
      where: cm.conversation_id == ^convo_id and cm.user_id in ^admins_to_remove
    )
    |> Repo.update_all(set: [is_admin: false])

    convo = Conversations.get_conversation!(convo_id) |> Repo.preload([conversation_members: [:user], messages: []])

    render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)
  else
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Only admins can modify admins"})
  end
end

# def members(conn, %{"id" => convo_id}) do
#   import Ecto.Query, only: [from: 2]

#   members =
#     from(cm in ConversationMember,
#       where: cm.conversation_id == ^convo_id,
#       join: u in assoc(cm, :user),
#       select: %{
#         user_id: u.id,
#         username: u.username,
#         avatar_data: Base.encode64(u.avatar_data || <<>>),
#         is_admin: cm.is_admin
#       }
#     )
#     |> Repo.all()

#   if members == [] do
#     case Repo.get(Conversation, convo_id) do
#       nil ->
#         conn
#         |> put_status(:not_found)
#         |> json(%{error: "Conversation not found"})

#       _ ->
#         conn
#         |> put_status(:ok)
#         |> json(members) # empty list
#     end
#   else
#     conn
#     |> put_status(:ok)
#     |> json(members)
#   end
# end

def members(conn, %{"id" => convo_id}) do
  import Ecto.Query, only: [from: 2]

  raw_members =
    from(cm in ConversationMember,
      where: cm.conversation_id == ^convo_id,
      join: u in assoc(cm, :user),
      select: %{
        user_id: u.id,
        username: u.username,
        avatar_data: u.avatar_data,
        is_admin: cm.is_admin
      }
    )
    |> Repo.all()

  members =
    Enum.map(raw_members, fn member ->
      %{
        user_id: member.user_id,
        username: member.username,
        avatar: Base.encode64(member.avatar_data || <<>>),
        is_admin: member.is_admin
      }
    end)

  if members == [] do
    case Repo.get(Conversation, convo_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Conversation not found"})

      _ ->
        conn
        |> put_status(:ok)
        |> json([])
    end
  else
    conn
    |> put_status(:ok)
    |> json(members)
  end
end



def details(conn, %{"id" => id}) do
  conversation =
    Conversation
    |> Repo.get(id)
    |> Repo.preload([:creator, conversation_members: [:user]])

  case conversation do
    nil ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Conversation not found"})

    convo ->
      members = Enum.map(convo.conversation_members, fn m ->
        %{
          id: m.user.id,
          username: m.user.username,
          avatar_data: Base.encode64(m.user.avatar_data || <<>>),
          is_admin: m.is_admin
        }
      end)

      json(conn, %{
        id: convo.id,
        group_name: convo.group_name,
        group_avatar_url: convo.group_avatar_url,
        created_by: convo.created_by,
        created_at: convo.inserted_at,
        creator: %{
          id: convo.creator.id,
          username: convo.creator.username,
          avatar_data: Base.encode64(convo.creator.avatar_data || <<>>),
        },
        members: members
      })
  end
end




  defp render_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
