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
  def create_conversation(%{
    "is_group" => is_group,
    "created_by" => created_by,
    "members" => members
  } = params) do
changeset = Conversation.changeset(%Conversation{}, params)

Repo.transaction(fn ->
  with {:ok, convo} <- Repo.insert(changeset) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

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
    convo
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
