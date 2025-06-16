defmodule WhatsappCloneWeb.MessageView do
  use WhatsappCloneWeb, :view

  def render("index.json", %{messages: messages}) do
    %{messages: render_many(messages, __MODULE__, "message.json")}
  end

  def render("message.json", %{message: msg}) do
    %{
      id: msg.id,
      sender_id: msg.sender_id,
      encrypted_body: msg.encrypted_body,
      message_type: msg.message_type,
      inserted_at: msg.inserted_at,
      attachments: render_attachments(msg.attachments || []),
      statuses: render_statuses(msg.status_entries || []),

      sender_display_name: msg.sender && msg.sender.display_name,
      # sender_avatar_data: msg.sender && msg.sender.avatar_data
      sender_avatar_data:
      if msg.sender && msg.sender.avatar_data do
        Base.encode64(msg.sender.avatar_data)
      else
        nil
      end
    }
  end

  # defp render_attachments(attachments) do
  #   Enum.map(attachments, fn a ->
  #     %{id: a.id, file_url: a.file_url, file_type: a.file_type}
  #   end)
  # end
  defp render_attachments(attachments) do
    Enum.map(attachments, fn a ->
      %{
        id: a.id,
        file_url: a.file_url,
        mime_type: a.mime_type,
        message_id: a.message_id,
        inserted_at: a.inserted_at,
        updated_at: a.updated_at
      }
    end)
  end


  # defp render_statuses(statuses) do
  #   Enum.map(statuses, fn s ->
  #     %{user_id: s.user_id, status: s.status, status_ts: s.status_ts}
  #   end)
  # end
  defp render_statuses(statuses) do
    Enum.map(statuses, fn s ->
      %{
        id: s.id,
        message_id: s.message_id,
        user_id: s.user_id,
        status: s.status,
        status_ts: s.status_ts,
        inserted_at: s.inserted_at,
        updated_at: s.updated_at,
        display_name: s.user && s.user.display_name,
        avatar_data:
          if s.user && s.user.avatar_data do
            Base.encode64(s.user.avatar_data)
          else
            nil
          end
      }
    end)
  end

end
