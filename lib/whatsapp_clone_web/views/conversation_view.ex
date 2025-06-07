defmodule WhatsappCloneWeb.ConversationView do
  use WhatsappCloneWeb, :view

  def render("index.json", %{conversations: conversations}) do
    %{data: render_many(conversations, __MODULE__, "conversation.json")}
  end

  def render("show.json", %{conversation: conversation}) do
    %{data: render_one(conversation, __MODULE__, "conversation.json")}
  end

  def render("conversation.json", %{conversation: convo}) do
    %{
      id: convo.id,
      is_group: convo.is_group,
      group_name: convo.group_name,
      group_avatar_url: convo.group_avatar_url,
      created_by: convo.created_by,
      inserted_at: convo.inserted_at,
      updated_at: convo.updated_at,
      last_message: render_last_message(convo)
    }
  end

  defp render_last_message(%{messages: []}), do: nil

  defp render_last_message(%{messages: [%{"id" => _} = m_json]}) do
    %{
      id: m_json["id"],
      sender_id: m_json["sender_id"],
      encrypted_body: m_json["encrypted_body"],
      message_type: m_json["message_type"],
      inserted_at: m_json["inserted_at"]
    }
  end
end
