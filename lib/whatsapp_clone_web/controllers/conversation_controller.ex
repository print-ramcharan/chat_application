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

#   def create(conn, %{
#     "is_group" => _,
#     "created_by" => _,
#     "members" => _
#   } = params) do
# case Conversations.create_conversation(params) do
#   {:ok, convo} ->
#     convo = Repo.preload(convo, [:conversation_members, :messages])
#     render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)

#   {:error, changeset} ->
#     conn
#     |> put_status(:unprocessable_entity)
#     |> json(%{errors: render_changeset_errors(changeset)})
# end
# end
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

# def create_conversation(attrs) do
#   members = Map.get(attrs, "members", [])
#   created_by = Map.get(attrs, "created_by")

#   # Build conversation changeset
#   %Conversation{}
#   |> Conversation.changeset(attrs)
#   |> Repo.insert()
#   |> case do
#     {:ok, convo} ->
#       # Insert members with admin flag
#       member_records = Enum.map(members, fn user_id ->
#         %{
#           conversation_id: convo.id,
#           user_id: user_id,
#           joined_at: DateTime.utc_now(),
#           is_admin: user_id == created_by
#         }
#       end)

#       Repo.insert_all(ConversationMember, member_records)
#       {:ok, Repo.preload(convo, [:conversation_members, :messages])}

#     error -> error
#   end
# end

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

    convo = Conversations.get_conversation!(convo_id) |> Repo.preload([:conversation_members, :messages])

    render(conn, WhatsappCloneWeb.ConversationView, "show.json", conversation: convo)
  else
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Only admins can modify admins"})
  end
end


  defp render_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
