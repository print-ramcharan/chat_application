defmodule WhatsappClone.Conversations do
  import Ecto.Query, warn: false
  alias WhatsappClone.{Repo, Conversation, ConversationMember}
  alias WhatsappClone.Message

    def list_user_conversations(user_id) do
      # Get ALL conversation IDs for this user first
      conversation_ids =
        from(cm in ConversationMember,
          where: cm.user_id == ^user_id,
          select: cm.conversation_id
        )
        |> Repo.all()

      # Return early if no conversations
      if Enum.empty?(conversation_ids) do
        []
      else
        # Fetch conversations with members
        conversations =
          from(c in Conversation,
            where: c.id in ^conversation_ids,
            preload: [conversation_members: :user],
            order_by: [desc: c.updated_at]
          )
          |> Repo.all()

        # Fetch last messages for ALL conversations in ONE query
        last_messages_subquery =
          from(m in Message,
            where: m.conversation_id in ^conversation_ids,
            distinct: m.conversation_id,
            order_by: [desc: m.inserted_at]
          )

        last_messages_map =
          last_messages_subquery
          |> Repo.all()
          |> Enum.group_by(& &1.conversation_id)
          |> Enum.map(fn {conv_id, [msg | _]} -> {conv_id, msg} end)
          |> Map.new()

        # Attach last messages to conversations
        Enum.map(conversations, fn conv ->
          Map.put(conv, :last_message, Map.get(last_messages_map, conv.id))
        end)
      end
    end

  defp map_to_conversation_struct(map) do
    last_msg =
      case map.last_message do
        nil -> []
        msg -> [msg]
      end

    %Conversation{
      id: map.id,
      is_group: map.is_group,
      group_name: map.group_name,
      group_avatar_url: map.group_avatar_url,
      created_by: map.created_by,
      inserted_at: map.inserted_at,
      # updated_at: map.updated_at,
      updated_at: Map.get(map, :updated_at),
      messages: last_msg
    }
  end

  def get_conversation(id) do
    Conversation
    |> Repo.get(id)
    |> Repo.preload([:conversation_members, :messages])
  end
  def get_conversation!(id) do
    Conversation
    |> Repo.get!(id)
    |> Repo.preload([:conversation_members, :messages])
  end


  def delete_conversation(%Conversation{} = conversation) do
    Repo.transaction(fn ->
      # Delete conversation members
      from(cm in ConversationMember, where: cm.conversation_id == ^conversation.id)
      |> Repo.delete_all()

      # Delete messages
      from(m in Message, where: m.conversation_id == ^conversation.id)
      |> Repo.delete_all()

      # Delete conversation itself
      Repo.delete(conversation)
    end)
  end

  # def create_conversation(%{
  #       "is_group" => is_group,
  #       "created_by" => created_by,
  #       "members" => members
  #     } = params) do
  #   changeset = Conversation.changeset(%Conversation{}, params)

  #   Repo.transaction(fn ->
  #     with {:ok, convo} <- Repo.insert(changeset) do
  #       now = DateTime.utc_now() |> DateTime.truncate(:second)

  #       rows =
  #         Enum.map(members, fn user_id ->
  #           %{
  #             id: Ecto.UUID.generate(),
  #             conversation_id: convo.id,
  #             user_id: user_id,
  #             joined_at: now,
  #             is_admin: user_id == created_by,
  #             inserted_at: now,
  #             updated_at: now
  #           }
  #         end)

  #       Repo.insert_all(ConversationMember, rows)
  #       convo
  #     else
  #       {:error, cs} -> Repo.rollback(cs)
  #     end
  #   end)
  # end
#   def create_conversation(%{
#     "is_group" => is_group,
#     "created_by" => created_by,
#     "members" => members
#   } = params) do
# changeset = Conversation.changeset(%Conversation{}, params)

# Repo.transaction(fn ->
#   with {:ok, convo} <- Repo.insert(changeset) do
#     now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

#     rows =
#       Enum.map(members, fn user_id ->
#         %{
#           id: Ecto.UUID.generate(),
#           conversation_id: convo.id,
#           user_id: user_id,
#           joined_at: now,
#           is_admin: user_id == created_by,
#           inserted_at: now,
#           updated_at: now
#         }
#       end)

#     Repo.insert_all(ConversationMember, rows)
#     convo
#   else
#     {:error, cs} -> Repo.rollback(cs)
#   end
# end)
# end

# def create_conversation(%{"is_group" => is_group,"created_by" => created_by,"members" => members} = params) do
#   changeset = Conversation.changeset(%Conversation{}, params)

#   Repo.transaction(fn ->
#     with {:ok, convo} <- Repo.insert(changeset) do
#       now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

#       rows =
#         Enum.map(members, fn user_id ->
#           %{
#             id: Ecto.UUID.generate(),
#             conversation_id: convo.id,
#             user_id: user_id,
#             joined_at: now,
#             is_admin: user_id == created_by,
#             inserted_at: now,
#             updated_at: now
#           }
#         end)

#       Repo.insert_all(ConversationMember, rows)

#       # ✅ Preload members and their users before returning
#       convo = Repo.preload(convo, conversation_members: [:user])
#       {:ok, convo}
#     else
#       {:error, cs} -> Repo.rollback(cs)
#     end
#   end)
# end

# def create_conversation(%{
#   "is_group" => is_group,
#   "created_by" => created_by,
#   "members" => members
# } = params) do
#   if is_group == false && length(members) == 2 do
#     sorted = Enum.sort(members)

#     # 🔒 Prevent private chat with self
#     if Enum.uniq(sorted) == 1 do
#       {:error, Ecto.Changeset.change(%Conversation{}, %{members: "Cannot create private chat with yourself"})}
#     else
#       # 🔒 Check if a private conversation already exists between the two users (in any order)
#       existing =
#         from(c in Conversation,
#           where: c.is_group == false,
#           join: m in assoc(c, :conversation_members),
#           group_by: c.id,
#           having: fragment("array_agg(?) ORDER BY ? ASC", m.user_id, m.user_id) == ^sorted,
#           select: count(c.id)
#         )
#         |> Repo.one()

#       if existing > 0 do
#         {:error, Ecto.Changeset.change(%Conversation{}, %{members: "Private conversation already exists"})}
#       else
#         do_create_conversation(params, created_by, members)
#       end
#     end
#   else
#     do_create_conversation(params, created_by, members)
#   end
# end
def get_one_on_one_conversation([user1_id, user2_id] = user_ids) do
  sorted_ids = Enum.sort(user_ids)

  # Dump UUIDs to binary format
  binary_uuids = Enum.map(sorted_ids, &Ecto.UUID.dump!/1)

  Conversation
  |> join(:inner, [c], cm in assoc(c, :conversation_members))
  |> where([c, _cm], not c.is_group)
  |> group_by([c, _cm], c.id)
  |> having([_c, cm], count(cm.user_id) == ^length(binary_uuids))
  |> having([_c, cm], fragment("array_agg(? ORDER BY ?) = ?", cm.user_id, cm.user_id, ^binary_uuids))
  |> Repo.one()
  |> Repo.preload(conversation_members: [:user])
end







def create_conversation(%{
  "is_group" => false,
  "created_by" => created_by,
  "members" => members
} = params) when length(members) == 2 do
  sorted = Enum.sort(members)

  if Enum.uniq(sorted) == 1 do
    {:error, Ecto.Changeset.change(%Conversation{}, %{members: "Cannot create private chat with yourself"})}
  else
    # Get conversations where is_group = false and has exactly these 2 users
    existing =
      from(c in Conversation,
        where: c.is_group == false,
        join: m in assoc(c, :conversation_members),
        group_by: c.id,
        having: fragment("array_agg(DISTINCT ? ORDER BY ?) = ?", m.user_id, m.user_id, ^sorted),
        select: count(c.id)
      )
      |> Repo.one()

    if existing > 0 do
      {:error, Ecto.Changeset.change(%Conversation{}, %{members: "Private conversation already exists"})}
    else
      do_create_conversation(params, created_by, members)
    end
  end
end

def create_conversation(params) do
  # Fallback for group or other types of convos
  do_create_conversation(params, params["created_by"], params["members"])
end


defp do_create_conversation(params, created_by, members) do
  changeset = Conversation.changeset(%Conversation{}, params)

  Repo.transaction(fn ->
    with {:ok, convo} <- Repo.insert(changeset) do
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      rows =
        Enum.map(members, fn user_id ->
          %{
            id: Ecto.UUID.generate(),
            conversation_id: convo.id,
            user_id: user_id,
            joined_at: now,
            is_admin: user_id == created_by,
            inserted_at: now,
            updated_at: now
          }
        end)

      Repo.insert_all(ConversationMember, rows)

      convo =
        convo
        |> Repo.preload([
          :messages,
          conversation_members: [:user]

        ])

      {:ok, convo}
    else
      {:error, cs} -> Repo.rollback(cs)
    end
  end)
end




  def update_conversation(id, attrs) do
    conversation = Repo.get!(Conversation, id)

    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  def user_in_conversation?(user_id, conversation_id) do
    Repo.get_by(ConversationMember, user_id: user_id, conversation_id: conversation_id) != nil
  end
end
