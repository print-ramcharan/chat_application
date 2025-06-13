# defmodule WhatsappCloneWeb.ChatChannel do
#   use WhatsappCloneWeb, :channel
#   alias WhatsappClone.Chat

#   def join("chat:" <> user_id, _payload, socket) do
#     # Optionally verify if user_id is authorized to join
#     {:ok, socket}
#   end

#   # def handle_in("send_message", %{"to" => to_id, "encrypted_body" => encrypted_body, "message_type" => message_type}, socket) do
#   #   from_user_id = socket.assigns.user_id

#   #   attrs = %{
#   #     sender_id: from_user_id,
#   #     conversation_id: to_id,
#   #     encrypted_body: encrypted_body,
#   #     message_type: String.to_existing_atom(message_type)
#   #   }

#   #   case Chat.create_message(attrs) do
#   #     {:ok, message} ->
#   #       # Broadcast message to the receiver's chat topic
#   #       WhatsappCloneWeb.Endpoint.broadcast("chat:#{to_id}", "new_message", %{
#   #         from: from_user_id,
#   #         encrypted_body: encrypted_body,
#   #         message_type: message.message_type,
#   #         inserted_at: message.inserted_at
#   #       })

#   #       {:reply, {:ok, %{status: "sent"}}, socket}

#   #     {:error, changeset} ->
#   #       {:reply, {:error, %{errors: changeset}}, socket}
#   #   end
#   # end
#   def handle_in("send_message", %{"to" => to_id, "encrypted_body" => encrypted_body, "message_type" => message_type}, socket) do
#     from_user_id = socket.assigns.user_id

#     WhatsappCloneWeb.Endpoint.broadcast("chat:#{to_id}", "new_message", %{
#       from: from_user_id,
#       encrypted_body: encrypted_body,
#       message_type: message_type,
#       inserted_at: DateTime.utc_now()
#     })

#     {:reply, {:ok, %{status: "sent"}}, socket}
#   end

# end

# defmodule WhatsappCloneWeb.ChatChannel do
#   use WhatsappCloneWeb, :channel
#   alias WhatsappClone.{Repo, Message}

#   def join("chat:" <> _user_id, _payload, socket) do
#     {:ok, socket}
#   end

#   def handle_in(
#         "send_message",
#         %{
#           "to" => conversation_id,
#           "encrypted_body" => encrypted_body,
#           "message_type" => message_type
#         },
#         socket
#       ) do
#     sender_id = socket.assigns.user_id

#     attrs = %{
#       sender_id: sender_id,
#       conversation_id: conversation_id,
#       encrypted_body: encrypted_body,
#       message_type: message_type
#     }

#     case Message.changeset(%Message{}, attrs) |> Repo.insert() do
#       {:ok, message} ->
#         WhatsappCloneWeb.Endpoint.broadcast("chat:#{conversation_id}", "new_message", %{
#           from: sender_id,
#           encrypted_body: message.encrypted_body,
#           message_type: message.message_type,
#           inserted_at: message.inserted_at
#         })

#         {:reply, {:ok, %{status: "sent"}}, socket}

#       {:error, changeset} ->
#         {:reply, {:error, %{errors: changeset}}, socket}
#     end
#   end
# end

# defmodule WhatsappCloneWeb.ChatChannel do
#   use WhatsappCloneWeb, :channel
#   alias WhatsappClone.{Repo, Message, MessageStatus}

#   def join("chat:" <> conversation_id, _payload, socket) do
#     {:ok, assign(socket, :conversation_id, conversation_id)}
#   end


#   # Existing message sending
#   def handle_in(
#         "send_message",
#         %{
#           "to" => conversation_id,
#           "encrypted_body" => encrypted_body,
#           "message_type" => message_type
#         },
#         socket
#       ) do
#     sender_id = socket.assigns.user_id

#     attrs = %{
#       sender_id: sender_id,
#       conversation_id: conversation_id,
#       encrypted_body: encrypted_body,
#       message_type: message_type
#     }

#     case Message.changeset(%Message{}, attrs) |> Repo.insert() do
#       {:ok, message} ->
#         # Insert initial message_status for sender (sent)
#         initial_status_attrs = %{
#           message_id: message.id,
#           user_id: sender_id,
#           status: "sent"
#         }
#         MessageStatus.changeset(%MessageStatus{}, initial_status_attrs) |> Repo.insert()

#         # Broadcast new message to conversation topic
#         WhatsappCloneWeb.Endpoint.broadcast("chat:#{conversation_id}", "new_message", %{
#           from: sender_id,
#           encrypted_body: message.encrypted_body,
#           message_type: message.message_type,
#           inserted_at: message.inserted_at,
#           message_id: message.id
#         })

#         {:reply, {:ok, %{status: "sent", message_id: message.id}}, socket}

#       {:error, changeset} ->
#         {:reply, {:error, %{errors: changeset}}, socket}
#     end
#   end

#   # New handler: update message status to delivered
#   def handle_in("message_delivered", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id

#     update_message_status(message_id, user_id, "delivered")

#     {:noreply, socket}
#   end

#   # New handler: update message status to read
#   def handle_in("message_read", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id

#     update_message_status(message_id, user_id, "read")

#     {:noreply, socket}
#   end

#   # Helper function to update or insert message_status
#   defp update_message_status(message_id, user_id, new_status) do
#     existing_status =
#       Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

#     changeset =
#       case existing_status do
#         nil ->
#           # Insert new status
#           MessageStatus.changeset(%MessageStatus{}, %{
#             message_id: message_id,
#             user_id: user_id,
#             status: new_status
#           })

#         status ->
#           # Update existing status only if new status is "higher"
#           if status_value(new_status) > status_value(status.status) do
#             MessageStatus.changeset(status, %{status: new_status, status_ts: DateTime.utc_now()})
#           else
#             nil
#           end
#       end

#     if changeset do
#       Repo.insert_or_update(changeset)
#     end
#   end

#   # Helper to order statuses so "read" > "delivered" > "sent"
#   defp status_value("sent"), do: 1
#   defp status_value("delivered"), do: 2
#   defp status_value("read"), do: 3
#   defp status_value(_), do: 0
# end

# defmodule WhatsappCloneWeb.ChatChannel do
#   use Phoenix.Channel
#   alias WhatsappClone.{Repo, Message, MessageStatus, ConversationMember}

#   @doc """
#   Clients join topic "chat:<conversation_id>"
#   """
#   def join("chat:" <> conversation_id, _params, socket) do
#     user_id = socket.assigns.user_id

#     case Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id) do
#       nil ->
#         {:error, %{reason: "unauthorized"}}

#       _member ->
#         socket = assign(socket, :conversation_id, conversation_id)

#         # ✅ Track presence (after assigning conversation_id)
#         WhatsappCloneWeb.Presence.track(
#           self(),
#           "chat:#{conversation_id}",
#           user_id,
#           %{online_at: inspect(System.system_time(:second))}
#         )

#         # ✅ Send current presence state
#         push(socket, "presence_state", WhatsappCloneWeb.Presence.list("chat:#{conversation_id}"))

#         {:ok, socket}
#     end
#   end


#   def handle_in("user_typing", _payload, socket) do
#     broadcast_from!(socket, "user_typing", %{user_id: socket.assigns.user_id})
#     {:noreply, socket}
#   end

#   @doc """
#   Handle inbound "send_message" event:

#     %{
#       "encrypted_body" => "...",
#       "message_type"   => "text" | "image" | ...
#     }

#   Broadcasts "new_message" to "chat:<conversation_id>" on success.
#   """
#   def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type}, socket) do
#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     attrs = %{
#       "sender_id" => user_id,
#       "conversation_id" => conversation_id,
#       "encrypted_body" => body,
#       "message_type" => type
#     }

#     case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#       {:ok, message} ->
#         # Insert initial status for the sender (sent)
#         %MessageStatus{}
#         |> MessageStatus.changeset(%{"message_id" => message.id, "user_id" => user_id, "status" => "sent"})
#         |> Repo.insert()

#         payload = %{
#           id: message.id,
#           sender_id: message.sender_id,
#           encrypted_body: message.encrypted_body,
#           message_type: message.message_type,
#           inserted_at: message.inserted_at
#         }

#         broadcast!(socket, "new_message", payload)
#         {:reply, {:ok, payload}, socket}

#       {:error, changeset} ->
#         {:reply, {:error, %{errors: Ecto.Changeset.traverse_errors(changeset, & &1)}}, socket}
#     end
#   end

#   @doc """
#   Handle updates to message status: "message_delivered" or "message_read"
#   Payload: %{"message_id" => "..."}
#   Broadcasts "message_status_update" to all in the conversation.
#   """
#   def handle_in("message_delivered", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     update_message_status(message_id, user_id, "delivered")
#     broadcast!(socket, "message_status_update", %{message_id: message_id, user_id: user_id, status: "delivered"})
#     {:noreply, socket}
#   end

#   def handle_in("message_read", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     update_message_status(message_id, user_id, "read")
#     broadcast!(socket, "message_status_update", %{message_id: message_id, user_id: user_id, status: "read"})
#     {:noreply, socket}
#   end

#   defp update_message_status(message_id, user_id, new_status) do
#     existing = Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

#     cond do
#       existing == nil ->
#         %MessageStatus{}
#         |> MessageStatus.changeset(%{"message_id" => message_id, "user_id" => user_id, "status" => new_status})
#         |> Repo.insert()

#       status_value(new_status) > status_value(existing.status) ->
#         existing
#         |> MessageStatus.changeset(%{"status" => new_status})
#         |> Repo.update()

#       true ->
#         {:ok, existing}
#     end
#   end

#   defp status_value("sent"), do: 1
#   defp status_value("delivered"), do: 2
#   defp status_value("read"), do: 3
#   defp status_value(_), do: 0
# end


defmodule WhatsappCloneWeb.ChatChannel do
  use Phoenix.Channel
  import Ecto.Query
  alias WhatsappClone.{Repo, Message, MessageStatus, ConversationMember}
  alias WhatsappCloneWeb.Presence

  @doc """
  Clients join topic "chat:<conversation_id>"
  """
  def join("chat:" <> conversation_id, _params, socket) do
    user_id = socket.assigns.user_id

    case Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id) do
      nil ->
        {:error, %{reason: "unauthorized"}}

      _member ->
        socket = assign(socket, :conversation_id, conversation_id)

        # Defer presence tracking and push to after join
        send(self(), :after_join)

        {:ok, socket}
    end
  end

  # def handle_in("update_message_status", %{"message_id" => message_id, "status" => status}, socket) do
  #   user_id = socket.assigns.user_id

  #   update_message_status(message_id, user_id, status)
  #   broadcast!(socket, "message_status_update", %{
  #     message_id: message_id,
  #     user_id: user_id,
  #     status: status
  #   })

  #   {:noreply, socket}
  # end
  def handle_in("update_message_status", %{
    "message_id" => message_id,
    "user_id" => user_id,
    "status" => status,
    "status_ts" => status_ts
  }, socket) do
# Update DB or forward to GenServer here
WhatsappClone.Messages.update_message_status(message_id, user_id, status, status_ts)

broadcast!(socket, "message_status_update", %{
  "message_id" => message_id,
  "user_id" => user_id,
  "status" => status
})

{:noreply, socket}
end
end

  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id
    conversation_id = socket.assigns.conversation_id

    Presence.track(
      self(),
      "chat:#{conversation_id}",
      user_id,
      %{online_at: inspect(System.system_time(:second))}
    )

    push(socket, "presence_state", Presence.list("chat:#{conversation_id}"))

    {:noreply, socket}
  end

  def handle_in("user_typing", _payload, socket) do
    broadcast_from!(socket, "user_typing", %{user_id: socket.assigns.user_id})
    {:noreply, socket}
  end

  def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type}, socket) do
    require Logger

    user_id = socket.assigns.user_id
    conversation_id = socket.assigns.conversation_id

    Logger.debug("✅ handle_in(send_message) called")
    Logger.debug("Socket assigns: #{inspect(socket.assigns)}")
    Logger.debug("Payload: body=#{body}, type=#{type}")
    attrs = %{
      "sender_id" => user_id,
      "conversation_id" => conversation_id,
      "encrypted_body" => body,
      "message_type" => type
    }

    case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
      {:ok, message} ->
        # timestamp =
        #   DateTime.utc_now()
        #   |> DateTime.to_naive()
        #   |> NaiveDateTime.truncate(:second)

        naive_timestamp =
          DateTime.utc_now()
          |> DateTime.to_naive()
          |> NaiveDateTime.truncate(:second)

        utc_timestamp =
          DateTime.utc_now()
          |> DateTime.truncate(:microsecond)


        # Get all conversation member user_ids
        member_ids =
          Repo.all(
            from cm in WhatsappClone.ConversationMember,
            where: cm.conversation_id == ^conversation_id,
            select: cm.user_id
          )

        # Get currently connected user IDs (you can adapt this logic)
        connected_ids = WhatsappCloneWeb.Presence.list("chat:#{conversation_id}") |> Map.keys()

        # Prepare message statuses
        statuses =
          Enum.map(member_ids, fn id ->
            status =
              cond do
                id == user_id -> "sent"
                id in connected_ids -> "read"
                true -> "pending"
              end

            %{
              message_id: message.id,
              user_id: id,
              status: status,
              status_ts: utc_timestamp,
              inserted_at: naive_timestamp,
              updated_at: naive_timestamp
            }
          end)

        # Bulk insert statuses
        Repo.insert_all(WhatsappClone.MessageStatus, statuses)

        payload = %{
          id: message.id,
          sender_id: message.sender_id,
          encrypted_body: message.encrypted_body,
          message_type: message.message_type,
          inserted_at: message.inserted_at,
          statuses: statuses
        }

        broadcast!(socket, "new_message", payload)
        {:reply, {:ok, payload}, socket}

      {:error, changeset} ->
        Logger.error("Failed to insert message: #{inspect(changeset.errors)}")
        {:reply, {:error, %{errors: Ecto.Changeset.traverse_errors(changeset, & &1)}}, socket}
    end
  end

  def handle_in("message_delivered", %{"message_id" => message_id}, socket) do
    user_id = socket.assigns.user_id

    update_message_status(message_id, user_id, "delivered")
    broadcast!(socket, "message_status_update", %{message_id: message_id, user_id: user_id, status: "delivered"})
    {:noreply, socket}
  end

  def handle_in("message_read", %{"message_id" => message_id}, socket) do
    user_id = socket.assigns.user_id

    update_message_status(message_id, user_id, "read")
    broadcast!(socket, "message_status_update", %{message_id: message_id, user_id: user_id, status: "read"})
    {:noreply, socket}
  end

  defp update_message_status(message_id, user_id, new_status) do
    existing = Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

    cond do
      existing == nil ->
        %MessageStatus{}
        |> MessageStatus.changeset(%{"message_id" => message_id, "user_id" => user_id, "status" => new_status})
        |> Repo.insert()

      status_value(new_status) > status_value(existing.status) ->
        existing
        |> MessageStatus.changeset(%{"status" => new_status})
        |> Repo.update()

      true ->
        {:ok, existing}
    end
  end

  defp status_value("sent"), do: 1
  defp status_value("delivered"), do: 2
  defp status_value("read"), do: 3
  defp status_value(_), do: 0
end
