defmodule WhatsappCloneWeb.MessageView do
  use WhatsappCloneWeb, :view

  def render("index.json", %{messages: messages}) do
    %{data: render_many(messages, __MODULE__, "message.json")}
  end

  def render("message.json", %{message: msg}) do
    %{
      id: msg.id,
      sender_id: msg.sender_id,
      encrypted_body: msg.encrypted_body,
      message_type: msg.message_type,
      inserted_at: msg.inserted_at,
      attachments: render_attachments(msg.attachments || []),
      statuses: render_statuses(msg.status_entries || [])
    }
  end

  defp render_attachments(attachments) do
    Enum.map(attachments, fn a ->
      %{id: a.id, file_url: a.file_url, file_type: a.file_type}
    end)
  end

  defp render_statuses(statuses) do
    Enum.map(statuses, fn s ->
      %{user_id: s.user_id, status: s.status, status_ts: s.status_ts}
    end)
  end
end
