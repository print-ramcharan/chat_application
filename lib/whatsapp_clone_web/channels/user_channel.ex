defmodule WhatsappCloneWeb.UserChannel do
  use WhatsappCloneWeb, :channel
  import Ecto.Query, only: [from: 2]

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
  # def handle_info(:after_join, socket) do
  #   user_id = to_string(socket.assigns.user_id)

  #   {:ok, _} = Presence.track(socket, user_id, %{
  #     online_at: System.system_time(:second)
  #   })

  #   # Optionally push full presence state to the user (if needed)
  #   push(socket, "presence_state", Presence.list(socket.topic))

  #   {:noreply, socket}
  # end
  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id

    {:ok, _} = Presence.track(socket, to_string(user_id), %{
      online_at: System.system_time(:second)
    })

    # Push full presence (optional)
    push(socket, "presence_state", Presence.list(socket.topic))

    # 💡 Update undelivered messages to DELIVERED
    Task.start(fn -> mark_messages_as_delivered(user_id) end)

    {:noreply, socket}
  end

  # defp mark_messages_as_delivered(user_id) do
  #   conversations = WhatsappClone.Conversations.list_user_conversations(user_id)

  #   Enum.each(conversations, fn convo ->
  #     messages = WhatsappClone.Messaging.list_undelivered_messages(convo.id, user_id)

  #     Enum.each(messages, fn message ->
  #       WhatsappClone.Messaging.update_message_status(
  #         message.id,
  #         user_id,
  #         "delivered",
  #         DateTime.utc_now()
  #       )

  #       # Optionally broadcast to the chat channel
  #       WhatsappCloneWeb.Endpoint.broadcast("chat:#{convo.id}", "message_status_update", %{
  #         message_id: message.id,
  #         user_id: user_id,
  #         status: "delivered"
  #       })
  #     end)
  #   end)
  # end
  defp mark_messages_as_delivered(user_id) do
    conversations = WhatsappClone.Conversations.list_user_conversations(user_id)

    Enum.each(conversations, fn convo ->
      messages = WhatsappClone.Messaging.list_undelivered_messages(convo.id, user_id)

      Enum.each(messages, fn message ->
        # Update status to "delivered"
        WhatsappClone.Messaging.update_message_status(
          message.id,
          user_id,
          "delivered",
          DateTime.utc_now()
        )

        # 🔄 Notify in chat channel
        WhatsappCloneWeb.Endpoint.broadcast("chat:#{convo.id}", "message_status_update", %{
          message_id: message.id,
          user_id: user_id,
          status: "delivered"
        })

        # 🔄 Notify sender in their user channel (if not the same user)
        if message.sender_id != user_id do
          fresh_statuses =
            from(ms in WhatsappClone.MessageStatus,
              where:
                ms.message_id == ^message.id and
                ms.user_id != ^message.sender_id
            )
            |> WhatsappClone.Repo.all()

          combined_status =
            WhatsappCloneWeb.ConversationView.compute_status_summary(fresh_statuses, message.sender_id)

          WhatsappCloneWeb.Endpoint.broadcast("user:#{message.sender_id}", "message_status_updated", %{
            "conversation_id" => convo.id,
            "message_id" => message.id,
            "updated_by" => user_id,
            "new_status" => combined_status || "sent"
          })
        end
      end)
    end)
  end






  # === Handle sending a direct message to a user ===
  def handle_in("new_message", %{
        "recipient_id" => recipient_id,
        "message_id" => message_id,
        "conversation_id" => conversation_id,
        "encrypted_body" => encrypted_body,
        "message_status" => message_status,
      }, socket) do
    Endpoint.broadcast("user:#{recipient_id}", "new_message", %{
      "message_id" => message_id,
      "conversation_id" => conversation_id,
      "encrypted_body" => encrypted_body,
      "message_status" => message_status,
    })

    {:noreply, socket}
  end

  def handle_in("mark_conversation_read", %{
    "user_id" => user_id,
    "conversation_id" => conversation_id
  }, socket) do
Endpoint.broadcast("user:#{user_id}", "unread_count_updated", %{
  "conversation_id" => conversation_id,
  "unread_count" => 0
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

  def handle_in("heartbeat", _payload, socket) do
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
