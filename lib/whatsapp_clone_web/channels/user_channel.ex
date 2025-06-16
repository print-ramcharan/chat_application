defmodule WhatsappCloneWeb.UserChannel do
  use WhatsappCloneWeb, :channel
  alias WhatsappCloneWeb.{Endpoint, Presence}

  # Authorize only the correct user to join their own topic
  def join("user:" <> user_id_str, _params, socket) do
    user_id = to_string(socket.assigns.user_id)

    if user_id == user_id_str do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Track user presence after successful join
  def handle_info(:after_join, socket) do
    user_id = to_string(socket.assigns.user_id)

    {:ok, _} = Presence.track(socket, user_id, %{
      online_at: System.system_time(:second)
    })

    # Optionally push full presence state to the user (if needed)
    push(socket, "presence_state", Presence.list(socket.topic))

    {:noreply, socket}
  end

  # === Handle sending a direct message to a user ===
  def handle_in("new_message", %{
        "recipient_id" => recipient_id,
        "message_id" => message_id,
        "conversation_id" => conversation_id,
        "encrypted_body" => encrypted_body
      }, socket) do
    Endpoint.broadcast("user:#{recipient_id}", "new_message", %{
      "message_id" => message_id,
      "conversation_id" => conversation_id,
      "encrypted_body" => encrypted_body
    })

    {:noreply, socket}
  end

  # === Friend Request Sent ===
  def handle_in("friend_request_sent", %{
        "to_user_id" => to_user_id,
        "from_user_id" => from_user_id,
        "from_username" => from_username
      }, socket) do
    Endpoint.broadcast("user:#{to_user_id}", "friend_request_received", %{
      "from_user_id" => from_user_id,
      "username" => from_username
    })

    {:noreply, socket}
  end

  # === Friend Request Accepted ===
  def handle_in("friend_request_accepted", %{
        "original_sender_id" => original_sender_id,
        "accepter_id" => accepter_id,
        "accepter_username" => accepter_username
      }, socket) do
    Endpoint.broadcast("user:#{original_sender_id}", "friend_request_accepted", %{
      "by_user_id" => accepter_id,
      "username" => accepter_username
    })

    {:noreply, socket}
  end
end
