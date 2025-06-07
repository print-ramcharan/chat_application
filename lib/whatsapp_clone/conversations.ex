defmodule WhatsappClone.Conversations do
  import Ecto.Query, warn: false
  alias WhatsappClone.{Repo, Conversation, ConversationMember}
  alias WhatsappClone.Message

  def list_user_conversations(user_id) do
    query =
      from c in Conversation,
        join: cm in ConversationMember, on: cm.conversation_id == c.id,
        where: cm.user_id == ^user_id,
        preload: [],
        group_by: c.id,
        select: %{
          id: c.id,
          is_group: c.is_group,
          group_name: c.group_name,
          group_avatar_url: c.group_avatar_url,
          created_by: c.created_by,
          inserted_at: c.inserted_at,
          last_message: fragment("""
            SELECT row_to_json(row)
            FROM (
              SELECT m2.id, m2.sender_id, m2.encrypted_body, m2.message_type, m2.inserted_at
              FROM messages m2
              WHERE m2.conversation_id = ?
              ORDER BY m2.inserted_at DESC
              LIMIT 1
            ) AS row
          """, c.id)
        }

    Repo.all(query)
    |> Enum.map(&map_to_conversation_struct/1)
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
      updated_at: map.updated_at,
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
