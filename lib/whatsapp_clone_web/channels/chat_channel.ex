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


# defmodule WhatsappCloneWeb.ChatChannel do
#   use Phoenix.Channel
#   import Ecto.Query
#   alias WhatsappClone.{Repo, Message, MessageStatus, ConversationMember}
#   alias WhatsappCloneWeb.Presence

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

#         # Defer presence tracking and push to after join
#         send(self(), :after_join)

#         {:ok, socket}
#     end
#   end

#   # def handle_in("update_message_status", %{"message_id" => message_id, "status" => status}, socket) do
#   #   user_id = socket.assigns.user_id

#   #   update_message_status(message_id, user_id, status)
#   #   broadcast!(socket, "message_status_update", %{
#   #     message_id: message_id,
#   #     user_id: user_id,
#   #     status: status
#   #   })

#   #   {:noreply, socket}
#   # end
#   def handle_in("update_message_status", %{
#     "message_id" => message_id,
#     "user_id" => user_id,
#     "status" => status,
#     "status_ts" => status_ts
#   }, socket) do
# # Update DB or forward to GenServer here
# WhatsappClone.Messages.update_message_status(message_id, user_id, status, status_ts)

# broadcast!(socket, "message_status_update", %{
#   "message_id" => message_id,
#   "user_id" => user_id,
#   "status" => status
# })

# {:noreply, socket}
# end
# end

#   def handle_info(:after_join, socket) do
#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     Presence.track(
#       self(),
#       "chat:#{conversation_id}",
#       user_id,
#       %{online_at: inspect(System.system_time(:second))}
#     )

#     push(socket, "presence_state", Presence.list("chat:#{conversation_id}"))

#     {:noreply, socket}
#   end

#   def handle_in("user_typing", _payload, socket) do
#     broadcast_from!(socket, "user_typing", %{user_id: socket.assigns.user_id})
#     {:noreply, socket}
#   end

#   def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type}, socket) do
#     require Logger

#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     Logger.debug("✅ handle_in(send_message) called")
#     Logger.debug("Socket assigns: #{inspect(socket.assigns)}")
#     Logger.debug("Payload: body=#{body}, type=#{type}")
#     attrs = %{
#       "sender_id" => user_id,
#       "conversation_id" => conversation_id,
#       "encrypted_body" => body,
#       "message_type" => type
#     }

#     case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#       {:ok, message} ->
#         # timestamp =
#         #   DateTime.utc_now()
#         #   |> DateTime.to_naive()
#         #   |> NaiveDateTime.truncate(:second)

#         naive_timestamp =
#           DateTime.utc_now()
#           |> DateTime.to_naive()
#           |> NaiveDateTime.truncate(:second)

#         utc_timestamp =
#           DateTime.utc_now()
#           |> DateTime.truncate(:microsecond)


#         # Get all conversation member user_ids
#         member_ids =
#           Repo.all(
#             from cm in WhatsappClone.ConversationMember,
#             where: cm.conversation_id == ^conversation_id,
#             select: cm.user_id
#           )

#         # Get currently connected user IDs (you can adapt this logic)
#         connected_ids = WhatsappCloneWeb.Presence.list("chat:#{conversation_id}") |> Map.keys()

#         # Prepare message statuses
#         statuses =
#           Enum.map(member_ids, fn id ->
#             status =
#               cond do
#                 id == user_id -> "sent"
#                 id in connected_ids -> "read"
#                 true -> "pending"
#               end

#             %{
#               message_id: message.id,
#               user_id: id,
#               status: status,
#               status_ts: utc_timestamp,
#               inserted_at: naive_timestamp,
#               updated_at: naive_timestamp
#             }
#           end)

#         # Bulk insert statuses
#         Repo.insert_all(WhatsappClone.MessageStatus, statuses)

#         payload = %{
#           id: message.id,
#           sender_id: message.sender_id,
#           encrypted_body: message.encrypted_body,
#           message_type: message.message_type,
#           inserted_at: message.inserted_at,
#           statuses: statuses
#         }

#         broadcast!(socket, "new_message", payload)
#         {:reply, {:ok, payload}, socket}

#       {:error, changeset} ->
#         Logger.error("Failed to insert message: #{inspect(changeset.errors)}")
#         {:reply, {:error, %{errors: Ecto.Changeset.traverse_errors(changeset, & &1)}}, socket}
#     end
#   end

#   def handle_in("message_delivered", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id

#     update_message_status(message_id, user_id, "delivered")
#     broadcast!(socket, "message_status_update", %{message_id: message_id, user_id: user_id, status: "delivered"})
#     {:noreply, socket}
#   end

#   def handle_in("message_read", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id

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


# defmodule WhatsappCloneWeb.ChatChannel do
#   use Phoenix.Channel
#   import Ecto.Query

#   alias WhatsappClone.{
#     Repo,
#     Message,
#     MessageStatus,
#     ConversationMember,
#     Messages
#   }

#   alias WhatsappCloneWeb.Presence

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
#         send(self(), :after_join)
#         {:ok, socket}
#     end
#   end

#   def handle_info(:after_join, socket) do
#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     Presence.track(
#       self(),
#       "chat:#{conversation_id}",
#       user_id,
#       %{online_at: inspect(System.system_time(:second))}
#     )

#     push(socket, "presence_state", Presence.list("chat:#{conversation_id}"))
#     {:noreply, socket}
#   end

#   def handle_in("user_typing", _payload, socket) do
#     broadcast_from!(socket, "user_typing", %{user_id: socket.assigns.user_id})
#     {:noreply, socket}
#   end

#   def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type}, socket) do
#     require Logger

#     user_id = socket.assigns.user_id
#     conversation_id = socket.assigns.conversation_id

#     Logger.debug("✅ handle_in(send_message) called")
#     Logger.debug("Socket assigns: #{inspect(socket.assigns)}")
#     Logger.debug("Payload: body=#{body}, type=#{type}")

#     attrs = %{
#       "sender_id" => user_id,
#       "conversation_id" => conversation_id,
#       "encrypted_body" => body,
#       "message_type" => type
#     }

#     case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#       {:ok, message} ->
#         naive_timestamp =
#           DateTime.utc_now()
#           |> DateTime.to_naive()
#           |> NaiveDateTime.truncate(:second)

#         utc_timestamp =
#           DateTime.utc_now()
#           |> DateTime.truncate(:microsecond)

#         member_ids =
#           Repo.all(
#             from cm in WhatsappClone.ConversationMember,
#             where: cm.conversation_id == ^conversation_id,
#             select: cm.user_id
#           )

#         connected_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()

#         statuses =
#           Enum.map(member_ids, fn id ->
#             status =
#               cond do
#                 id == user_id -> "sent"
#                 id in connected_ids -> "read"
#                 true -> "pending"
#               end

#             %{
#               message_id: message.id,
#               user_id: id,
#               status: status,
#               status_ts: utc_timestamp,
#               inserted_at: naive_timestamp,
#               updated_at: naive_timestamp
#             }
#           end)

#         Repo.insert_all(MessageStatus, statuses)

#         payload = %{
#           id: message.id,
#           sender_id: message.sender_id,
#           encrypted_body: message.encrypted_body,
#           message_type: message.message_type,
#           inserted_at: message.inserted_at,
#           statuses: statuses
#         }

#         # broadcast!(socket, "new_message", payload)
#         # {:reply, {:ok, payload}, socket}


#         # Broadcast to users in this chat
#         broadcast!(socket, "new_message", payload)

#         # ALSO broadcast to each user (excluding sender) via user:<user_id> channel
#         Enum.each(member_ids, fn id ->
#           if id != user_id do
#             WhatsappCloneWeb.Endpoint.broadcast("user:#{id}", "new_message_notification", %{
#               conversation_id: conversation_id,
#               message_id: message.id,
#               sender_id: user_id,
#               message_preview: body,
#               message_type: type,
#               timestamp: message.inserted_at
#             })
#           end
#         end)

#         {:reply, {:ok, payload}, socket}

#       {:error, changeset} ->
#         Logger.error("Failed to insert message: #{inspect(changeset.errors)}")

#         {:reply,
#          {:error,
#           %{errors: Ecto.Changeset.traverse_errors(changeset, & &1)}},
#          socket}
#     end
#   end

#   def handle_in("update_message_status", %{
#         "message_id" => message_id,
#         "user_id" => user_id,
#         "status" => status,
#         "status_ts" => status_ts
#       }, socket) do
#     # Forward to your Messages context (expected to handle DB logic)
#     Messages.update_message_status(message_id, user_id, status, status_ts)

#     broadcast!(socket, "message_status_update", %{
#       message_id: message_id,
#       user_id: user_id,
#       status: status
#     })

#     {:noreply, socket}
#   end

#   def handle_in("message_delivered", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id

#     update_message_status(message_id, user_id, "delivered")

#     broadcast!(socket, "message_status_update", %{
#       message_id: message_id,
#       user_id: user_id,
#       status: "delivered"
#     })

#     {:noreply, socket}
#   end

#   def handle_in("message_read", %{"message_id" => message_id}, socket) do
#     user_id = socket.assigns.user_id

#     update_message_status(message_id, user_id, "read")

#     broadcast!(socket, "message_status_update", %{
#       message_id: message_id,
#       user_id: user_id,
#       status: "read"
#     })

#     {:noreply, socket}
#   end

#   defp update_message_status(message_id, user_id, new_status) do
#     existing = Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

#     cond do
#       existing == nil ->
#         %MessageStatus{}
#         |> MessageStatus.changeset(%{
#           "message_id" => message_id,
#           "user_id" => user_id,
#           "status" => new_status
#         })
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

# extra code here

 # def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type}, socket) do
  #   user_id = socket.assigns.user_id
  #   conversation_id = socket.assigns.conversation_id

  #   attrs = %{
  #     "sender_id" => user_id,
  #     "conversation_id" => conversation_id,
  #     "encrypted_body" => body,
  #     "message_type" => type
  #   }

  #   case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
  #     {:ok, message} ->
  #       timestamp = DateTime.utc_now() |> DateTime.truncate(:microsecond)
  #       naive = DateTime.to_naive(timestamp)

  #       member_ids =
  #         Repo.all(from cm in ConversationMember,
  #                  where: cm.conversation_id == ^conversation_id,
  #                  select: cm.user_id)

  #       online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()

  #       statuses = Enum.map(member_ids, fn id ->
  #         %{
  #           message_id: message.id,
  #           user_id: id,
  #           status: status_for(id, user_id, online_ids),
  #           status_ts: timestamp,
  #           inserted_at: naive,
  #           updated_at: naive
  #         }
  #       end)

  #       Repo.insert_all(MessageStatus, statuses)

  #       payload = %{
  #         id: message.id,
  #         sender_id: user_id,
  #         encrypted_body: body,
  #         message_type: type,
  #         inserted_at: message.inserted_at,
  #         statuses: statuses
  #       }

  #       broadcast!(socket, "new_message", payload)

  #       # Push real-time notification to each user (except sender)
  #       Enum.each(member_ids, fn id ->
  #         if id != user_id do
  #           Endpoint.broadcast("user:#{id}", "new_message", %{
  #             conversation_id: conversation_id,
  #             message_id: message.id,
  #             encrypted_body: body,
  #             message_type: type,
  #             sender_id: user_id,
  #             inserted_at: message.inserted_at
  #           })
  #         end
  #       end)

  #       {:reply, {:ok, payload}, socket}

  #     {:error, changeset} ->
  #       {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
  #   end
  # end

  # def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type}, socket) do
  #   with {:ok, user_id} <- fetch_assign(socket, :user_id),
  #        {:ok, conversation_id} <- fetch_assign(socket, :conversation_id) do

  #     attrs = %{
  #       "sender_id" => user_id,
  #       "conversation_id" => conversation_id,
  #       "encrypted_body" => body,
  #       "message_type" => type
  #     }

  #     case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
  #       {:ok, message} ->
  #         timestamp = DateTime.utc_now() |> DateTime.truncate(:microsecond)
  #         naive = DateTime.to_naive(timestamp)

  #         member_ids =
  #           Repo.all(from cm in ConversationMember,
  #                    where: cm.conversation_id == ^conversation_id,
  #                    select: cm.user_id)

  #         online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()

  #         statuses = Enum.map(member_ids, fn id ->
  #           %{
  #             message_id: message.id,
  #             user_id: id,
  #             status: status_for(id, user_id, online_ids),
  #             status_ts: timestamp,
  #             inserted_at: naive,
  #             updated_at: naive
  #           }
  #         end)

  #         Repo.insert_all(MessageStatus, statuses)

  #         payload = %{
  #           id: message.id,
  #           sender_id: user_id,
  #           encrypted_body: body,
  #           message_type: type,
  #           inserted_at: message.inserted_at,
  #           statuses: statuses
  #         }

  #         broadcast!(socket, "new_message", payload)

  #         Enum.each(member_ids, fn id ->
  #           if id != user_id do
  #             Endpoint.broadcast("user:#{id}", "new_message", %{
  #               conversation_id: conversation_id,
  #               message_id: message.id,
  #               encrypted_body: body,
  #               message_type: type,
  #               sender_id: user_id,
  #               inserted_at: message.inserted_at
  #             })
  #           end
  #         end)

  #         {:reply, {:ok, payload}, socket}

  #       {:error, changeset} ->
  #         {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
  #     end
  #   else
  #     _ -> {:reply, {:error, %{reason: "Missing user or conversation context"}}, socket}
  #   end
  # end



# def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type, "client_ref" => client_ref}, socket) do
#   user_id = socket.assigns.user_id
#   conversation_id = socket.assigns.conversation_id

#   # WhatsappCloneWeb.DebugPresence.log_all_user_presences()

#   attrs = %{
#     "sender_id" => user_id,
#     "conversation_id" => conversation_id,
#     "encrypted_body" => body,
#     "message_type" => type,
#     "client_ref" => client_ref
#   }

#   case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#     {:ok, message} ->
#       timestamp = DateTime.utc_now() |> DateTime.truncate(:microsecond)
#       naive = DateTime.to_naive(timestamp) |> NaiveDateTime.truncate(:second)

#       member_ids =
#         Repo.all(from cm in ConversationMember,
#                  where: cm.conversation_id == ^conversation_id,
#                  select: cm.user_id)

#       online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()

#       statuses = Enum.map(member_ids, fn id ->
#         %{
#           message_id: message.id,
#           user_id: id,
#           status: status_for(id, user_id, online_ids),
#           status_ts: timestamp,
#           inserted_at: naive,
#           updated_at: naive
#         }
#       end)

#       Repo.insert_all(MessageStatus, statuses)

#       # Fetch sender info
#       sender_user =
#         Repo.one(
#           from u in WhatsappClone.User,
#           where: u.id == ^user_id,
#           select: %{
#             id: u.id,
#             display_name: u.display_name,
#             avatar_data: fragment("encode(?, 'base64')", u.avatar_data)
#           }
#         )

#       # Broadcast minimal message + sender info to all chat participants
#       broadcast_payload = %{
#         id: message.id,
#         sender_id: user_id,
#         sender_display_name: sender_user.display_name,
#         sender_avatar_data: sender_user.avatar_data,
#         encrypted_body: body,
#         message_type: type,
#         inserted_at: message.inserted_at,
#         client_ref: client_ref
#       }

#       # Logger.debug(">>> Broadcasting: #{inspect(broadcast_payload)}")
# # broadcast!(socket, "new_message", broadcast_payload)

# # push(socket, "new_message", broadcast_payload)
# broadcast_from!(socket, "new_message", broadcast_payload)
#       # broadcast!(socket, "new_message", broadcast_payload)

#       # Push background update to other members via user:* channel
#       Enum.each(member_ids, fn id ->
#         if id != user_id do
#           Endpoint.broadcast("user:#{id}", "new_message", %{
#             conversation_id: conversation_id,
#             message_id: message.id,
#             encrypted_body: body,
#             message_type: type,
#             sender_id: user_id,
#             inserted_at: message.inserted_at,
#             client_ref: client_ref
#           })
#         end
#       end)

#       # Fetch all user info for statuses
#       users =
#         Repo.all(
#           from u in WhatsappClone.User,
#           where: u.id in ^member_ids,
#           select: %{
#             id: u.id,
#             display_name: u.display_name,
#             avatar_data: fragment("encode(?, 'base64')", u.avatar_data)
#           }
#         )

#       user_map = Map.new(users, fn u -> {u.id, u} end)

#       statuses_with_user =
#         Enum.map(statuses, fn s ->
#           Map.merge(s, Map.get(user_map, s.user_id) || %{})
#         end)

#         Enum.each(statuses_with_user, fn status ->
#           Logger.debug("🟨 Status user info — ID: #{status.user_id}, Name: #{inspect(status.display_name)}, Avatar: #{String.slice(to_string(status.avatar_data || ""), 0, 20)}...")
#         end)


#       {:reply, {:ok, %{message: broadcast_payload, statuses: statuses_with_user}}, socket}

#     {:error, changeset} ->
#       {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
#   end
# end


defmodule WhatsappCloneWeb.ChatChannel do
  use Phoenix.Channel
  import Ecto.Query
  alias Ecto.UUID
  alias WhatsappClone.{Repo, Message, MessageStatus, ConversationMember, Messages}
  alias WhatsappCloneWeb.{Endpoint, Presence}
  alias WhatsappClone.User
  require Logger



  # Clients join topic: "chat:<conversation_id>"
  def join("chat:" <> conversation_id, _params, socket) do
    user_id = socket.assigns.user_id

    case Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id) do
      nil -> {:error, %{reason: "unauthorized"}}
      _ ->
        socket = assign(socket, :conversation_id, conversation_id)
        send(self(), :after_join)
        {:ok, socket}
    end
  end

  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id
    conversation_id = socket.assigns.conversation_id

    Presence.track(self(), "chat:#{conversation_id}", user_id, %{
      online_at: inspect(System.system_time(:second))
    })

    push(socket, "presence_state", Presence.list("chat:#{conversation_id}"))
    {:noreply, socket}
  end
  def handle_in("sync_presence", _params, socket) do
    conversation_id = socket.assigns.conversation_id
    push(socket, "presence_state", Presence.list("chat:#{conversation_id}"))
    {:noreply, socket}
  end


  def handle_in("user_typing", _payload, socket) do
    broadcast_from!(socket, "user_typing", %{user_id: socket.assigns.user_id})
    {:noreply, socket}
  end

def handle_in("heartbeat", _payload, socket) do
  {:noreply, socket}
end

# def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type, "client_ref" => client_ref}, socket) do
#   user_id = socket.assigns.user_id
#   conversation_id = socket.assigns.conversation_id

#   attrs = %{
#     "sender_id" => user_id,
#     "conversation_id" => conversation_id,
#     "encrypted_body" => body,
#     "message_type" => type,
#     "client_ref" => client_ref
#   }

#   case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#     {:ok, message} ->
#       timestamp = DateTime.utc_now() |> DateTime.truncate(:microsecond)
#       naive = DateTime.to_naive(timestamp) |> NaiveDateTime.truncate(:second)

#       member_ids =
#         Repo.all(from cm in ConversationMember,
#                  where: cm.conversation_id == ^conversation_id,
#                  select: cm.user_id)

#       online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()

#       statuses = Enum.map(member_ids, fn id ->
#         %{
#           message_id: message.id,
#           user_id: id,
#           status: status_for(id, user_id, online_ids),
#           status_ts: timestamp,
#           inserted_at: naive,
#           updated_at: naive
#         }
#       end)

#       Repo.insert_all(MessageStatus, statuses)

#       # Fetch sender info
#       sender_user =
#         Repo.one(
#           from u in WhatsappClone.User,
#           where: u.id == ^user_id,
#           select: %{
#             id: u.id,
#             display_name: u.display_name,
#             avatar_data: fragment("encode(?, 'base64')", u.avatar_data)
#           }
#         )

#       # Broadcast minimal message + sender info to all chat participants
#       broadcast_payload = %{
#         id: message.id,
#         sender_id: user_id,
#         sender_display_name: sender_user.display_name,
#         sender_avatar_data: sender_user.avatar_data,
#         encrypted_body: body,
#         message_type: type,
#         inserted_at: message.inserted_at,
#         client_ref: client_ref
#       }

#       # Logger.debug(">>> Broadcasting: #{inspect(broadcast_payload)}")
# # broadcast!(socket, "new_message", broadcast_payload)

# # push(socket, "new_message", broadcast_payload)
# broadcast_from!(socket, "new_message", broadcast_payload)
#       # broadcast!(socket, "new_message", broadcast_payload)

#       # Push background update to other members via user:* channel
#       Enum.each(member_ids, fn id ->
#         if id != user_id do
#           Endpoint.broadcast("user:#{id}", "new_message", %{
#             conversation_id: conversation_id,
#             message_id: message.id,
#             encrypted_body: body,
#             message_type: type,
#             sender_id: user_id,
#             inserted_at: message.inserted_at,
#             client_ref: client_ref
#           })

#           # 🔥 Add this block here
#           unless id in online_ids do
#             fcm_token =
#               Repo.one(
#                 from u in WhatsappClone.User,
#                 where: u.id == ^id,
#                 select: u.fcm_token
#               )

#             if fcm_token do
#               # WhatsappClone.Notifier.send_fcm_message(fcm_token, %{
#               #   title: "New message",
#               #   body: "#{sender_user.display_name} sent you a message",
#               #   data: %{
#               #     "message_id" => to_string(message.id)
#               #   }

#               # })
#               WhatsappClone.Notifier.send_fcm_message(fcm_token, %{
#                 title: "New message",
#                 body: "#{sender_user.display_name}: #{body}",
#                 data: %{
#                   "message_id" => to_string(message.id),
#                   "sender_id" => to_string(user_id),
#                   "conversation_id" => to_string(conversation_id),
#                   "encrypted_body" => body,
#                   "message_type" => type,
#                   "inserted_at" => DateTime.to_iso8601(message.inserted_at),
#                   "client_ref" => client_ref,
#                   "sender_name" => sender_user.display_name
#                 }
#               })



#             end
#           end
#         end
#       end)


#       # Fetch all user info for statuses
#       users =
#         Repo.all(
#           from u in WhatsappClone.User,
#           where: u.id in ^member_ids,
#           select: %{
#             id: u.id,
#             display_name: u.display_name,
#             avatar_data: fragment("encode(?, 'base64')", u.avatar_data)
#           }
#         )

#       user_map = Map.new(users, fn u -> {u.id, u} end)

#       statuses_with_user =
#         Enum.map(statuses, fn s ->
#           Map.merge(s, Map.get(user_map, s.user_id) || %{})
#         end)

#         Enum.each(statuses_with_user, fn status ->
#           Logger.debug("🟨 Status user info — ID: #{status.user_id}, Name: #{inspect(status.display_name)}, Avatar: #{String.slice(to_string(status.avatar_data || ""), 0, 20)}...")
#         end)


#       {:reply, {:ok, %{message: broadcast_payload, statuses: statuses_with_user}}, socket}

#     {:error, changeset} ->
#       {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
#   end
# end

  defp fetch_assign(socket, key) do
    case Map.fetch(socket.assigns, key) do
      :error -> {:error, :missing}
      ok -> ok
    end
  end

  def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type, "client_ref" => client_ref}, socket) do
    user_id = socket.assigns.user_id
    conversation_id = socket.assigns.conversation_id

    attrs = %{
      "sender_id" => user_id,
      "conversation_id" => conversation_id,
      "encrypted_body" => body,
      "message_type" => type,
      "client_ref" => client_ref
    }

    case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
      {:ok, message} ->
        timestamp = DateTime.utc_now() |> DateTime.truncate(:microsecond)
        naive = DateTime.to_naive(timestamp) |> NaiveDateTime.truncate(:second)

        member_ids =
          Repo.all(from cm in ConversationMember,
                   where: cm.conversation_id == ^conversation_id,
                   select: cm.user_id)

        chat_online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()
        user_online_ids = Enum.map(member_ids, fn id ->
          if is_user_online?(id), do: id, else: nil
        end) |> Enum.reject(&is_nil/1)


        statuses = Enum.map(member_ids, fn id ->
          %{
            message_id: message.id,
            user_id: id,
            status: status_for(id, user_id, chat_online_ids, user_online_ids),
            status_ts: timestamp,
            inserted_at: naive,
            updated_at: naive
          }
        end)

        Repo.insert_all(MessageStatus, statuses)

        # Fetch sender info
        sender_user =
          Repo.one(
            from u in WhatsappClone.User,
            where: u.id == ^user_id,
            select: %{
              id: u.id,
              display_name: u.display_name,
              avatar_data: fragment("encode(?, 'base64')", u.avatar_data)
            }
          )

        # Broadcast minimal message + sender info to all chat participants
        broadcast_payload = %{
          id: message.id,
          sender_id: user_id,
          sender_display_name: sender_user.display_name,
          sender_avatar_data: sender_user.avatar_data,
          encrypted_body: body,
          message_type: type,
          inserted_at: message.inserted_at,
          client_ref: client_ref
        }

        # Logger.debug(">>> Broadcasting: #{inspect(broadcast_payload)}")
  # broadcast!(socket, "new_message", broadcast_payload)

  # push(socket, "new_message", broadcast_payload)
  broadcast_from!(socket, "new_message", broadcast_payload)
        # broadcast!(socket, "new_message", broadcast_payload)

        # Push background update to other members via user:* channel
        Enum.each(member_ids, fn id ->
          if id != user_id do
            # Only consider statuses of OTHER members, excluding the sender
            other_statuses = Enum.filter(statuses, fn s -> s.user_id != user_id end)

            combined_status =
              cond do
                Enum.all?(other_statuses, &(&1.status == "read")) -> "read"
                Enum.any?(other_statuses, &(&1.status == "delivered")) -> "delivered"
                true -> "sent"
              end

            Endpoint.broadcast("user:#{id}", "new_message", %{
              conversation_id: conversation_id,
              message_id: message.id,
              encrypted_body: body,
              message_type: type,
              sender_id: user_id,
              inserted_at: message.inserted_at,
              client_ref: client_ref,
              message_status: combined_status
            })


            # 🔥 Add this block here
            unless id in chat_online_ids or id in user_online_ids do
              fcm_token =
                Repo.one(
                  from u in WhatsappClone.User,
                  where: u.id == ^id,
                  select: u.fcm_token
                )

              if fcm_token do
                # WhatsappClone.Notifier.send_fcm_message(fcm_token, %{
                #   title: "New message",
                #   body: "#{sender_user.display_name} sent you a message",
                #   data: %{
                #     "message_id" => to_string(message.id)
                #   }

                # })
                WhatsappClone.Notifier.send_fcm_message(fcm_token, %{
                  title: "New message",
                  body: "#{sender_user.display_name}: #{body}",
                  data: %{
                    "message_id" => to_string(message.id),
                    "sender_id" => to_string(user_id),
                    "conversation_id" => to_string(conversation_id),
                    "encrypted_body" => body,
                    "message_type" => type,
                    "inserted_at" => DateTime.to_iso8601(message.inserted_at),
                    "client_ref" => client_ref,
                    "sender_name" => sender_user.display_name
                  }
                })



              end
            end
          end
        end)


        # Fetch all user info for statuses
        users =
          Repo.all(
            from u in WhatsappClone.User,
            where: u.id in ^member_ids,
            select: %{
              id: u.id,
              display_name: u.display_name,
              avatar_data: fragment("encode(?, 'base64')", u.avatar_data)
            }
          )

        user_map = Map.new(users, fn u -> {u.id, u} end)

        statuses_with_user =
          Enum.map(statuses, fn s ->
            Map.merge(s, Map.get(user_map, s.user_id) || %{})
          end)

          Enum.each(statuses_with_user, fn status ->
            Logger.debug("🟨 Status user info — ID: #{status.user_id}, Name: #{inspect(status.display_name)}, Avatar: #{String.slice(to_string(status.avatar_data || ""), 0, 20)}...")
          end)


        {:reply, {:ok, %{message: broadcast_payload, statuses: statuses_with_user}}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
    end
  end
  # defp status_for(id, sender_id, online_ids) do
  #   cond do
  #     id == sender_id ->
  #       Logger.debug("Status for #{id}: sender -> sent")
  #       "sent"

  #     id in online_ids ->
  #       Logger.debug("Status for #{id}: present in chat -> read")
  #       "read"

  #     is_user_online?(id) ->
  #       Logger.debug("Status for #{id}: online in user:* channel -> delivered")
  #       "delivered"

  #     true ->
  #       Logger.debug("Status for #{id}: offline -> sent")
  #       "sent"
  #   end
  # end

  defp status_for(user_id, sender_id, chat_online_ids, user_online_ids) do
    cond do
      user_id == sender_id ->
        "sent"

      user_id in chat_online_ids ->
        "read"

      user_id in user_online_ids or is_user_online?(user_id) ->
        "delivered"

      true ->
        "sent"
    end
  end


  def handle_in("group_info_updated", %{"group_id" => group_id} = params, socket) do
    case Repo.get(WhatsappClone.Conversation, group_id) do
      nil ->
        {:reply, {:error, %{reason: "Conversation not found"}}, socket}

      conversation ->
        changes =
          params
          |> Map.take(["group_name", "group_avatar_url"])
          |> Enum.reduce(%{}, fn
            {"group_name", name}, acc when is_binary(name) and byte_size(name) > 0 ->
              Map.put(acc, :group_name, name)

            {"group_avatar_url", base64}, acc when is_binary(base64) ->
              case Base.decode64(base64) do
                {:ok, decoded} -> Map.put(acc, :group_avatar_url, decoded)
                :error ->
                  Logger.warn("Invalid Base64 string for avatar")
                  acc
              end

            _, acc -> acc
          end)

        if map_size(changes) > 0 do
          changeset = Ecto.Changeset.change(conversation, changes)

          case Repo.update(changeset) do
            {:ok, updated} ->
              broadcast_from!(socket, "group_info_updated", %{
                "group_id" => updated.id,
                "group_name" => updated.group_name,
                "group_avatar_url" =>
                  if updated.group_avatar_url do
                    Base.encode64(updated.group_avatar_url)
                  else
                    nil
                  end
              })

              {:reply, {:ok, %{message: "Group updated"}}, socket}

            {:error, changeset} ->
              {:reply, {:error, %{reason: "Update failed", errors: changeset}}, socket}
          end
        else
          {:reply, {:error, %{reason: "No valid fields to update"}}, socket}
        end
    end
  end


  def handle_in("message_delivered", %{"message_id" => message_id}, socket) do
    update_message_status(message_id, socket.assigns.user_id, "delivered")

    broadcast!(socket, "message_status_update", %{
      message_id: message_id,
      user_id: socket.assigns.user_id,
      status: "delivered"
    })

    {:noreply, socket}
  end

  def handle_in("message_read", %{"message_id" => message_id}, socket) do
    update_message_status(message_id, socket.assigns.user_id, "read")

    broadcast!(socket, "message_status_update", %{
      message_id: message_id,
      user_id: socket.assigns.user_id,
      status: "read"
    })

    {:noreply, socket}
  end

  def handle_in("group_info_updated", %{"group_id" => group_id} = params, socket) do
    case Repo.get(Conversation, group_id) do
      nil ->
        {:reply, {:error, %{reason: "Conversation not found"}}, socket}

      conversation ->
        changes = %{}

        # Handle name update
        changes =
          if Map.has_key?(params, "group_name") do
            Map.put(changes, :group_name, params["group_name"])
          else
            changes
          end

        # Handle avatar update (Base64 -> bytea)
        changes =
          if Map.has_key?(params, "group_avatar_url") do
            case Base.decode64(params["group_avatar_url"]) do
              {:ok, decoded} -> Map.put(changes, :group_avatar_url, decoded)
              :error ->
                Logger.warn("Invalid Base64 avatar string")
                changes
            end
          else
            changes
          end

        # Only update if there's something to update
        if map_size(changes) > 0 do
          changeset = Ecto.Changeset.change(conversation, changes)

          case Repo.update(changeset) do
            {:ok, updated} ->
              broadcast_from!(socket, "group_info_updated", %{
                "group_id" => updated.id,
                "group_name" => updated.group_name,
                "group_avatar_url" => if(updated.group_avatar_url, do: Base.encode64(updated.group_avatar_url), else: nil)
              })

              {:reply, {:ok, %{message: "Group updated"}}, socket}

            {:error, changeset} ->
              {:reply, {:error, %{reason: "Validation failed", errors: changeset}}, socket}
          end
        else
          {:reply, {:error, %{reason: "No valid fields to update"}}, socket}
        end
      end
    end



  def handle_in("update_message_status", %{
        "message_id" => message_id,
        "user_id" => user_id,
        "status" => status,
        "status_ts" => status_ts
      }, socket) do
    # Forward to your Messages context (expected to handle DB logic)
    WhatsappClone.Messaging.update_message_status(message_id, user_id, status, status_ts)

    broadcast!(socket, "message_status_update", %{
      message_id: message_id,
      user_id: user_id,
      status: status
    })

#     with %WhatsappClone.Message{sender_id: sender_id, conversation_id: conv_id} <-
#       Repo.get(WhatsappClone.Message, message_id),
#     true <- sender_id != user_id do

#  # Push back to the original sender via user channel
#     WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
#       conversation_id: conv_id,
#       message_id: message_id,
#       updated_by: user_id,
#       new_status: status
#     })
#     end

      with %WhatsappClone.Message{sender_id: sender_id, conversation_id: conv_id} <-
        Repo.get(WhatsappClone.Message, message_id),
      true <- sender_id != user_id do

      # Fetch all statuses for the message except sender
      other_statuses =
      from(ms in WhatsappClone.MessageStatus,
      where: ms.message_id == ^message_id and ms.user_id != ^sender_id,
      select: ms.status
      )
      |> Repo.all()

      # Define status priority
      status_priority = ["pending", "sent", "delivered", "read"]

      # Find the highest-priority (lowest index) status among other users
      combined_status =
      Enum.reduce(other_statuses, "read", fn status, acc ->
      if Enum.find_index(status_priority, &(&1 == status)) <
            Enum.find_index(status_priority, &(&1 == acc)),
          do: status,
          else: acc
      end)

      # Push back to the original sender with updated combined status
      WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
      conversation_id: conv_id,
      message_id: message_id,
      updated_by: user_id,
      new_status: combined_status
      })
      end



    {:noreply, socket}
  end

  defp is_user_online?(user_id) do
    key = to_string(user_id)
    topic = "user:#{key}"

    presence_list = WhatsappCloneWeb.Presence.list(topic)
    is_online = Map.has_key?(presence_list, key)

    Logger.debug("Checking presence on topic #{topic}")
    Logger.debug("Presence data: #{inspect(presence_list)}")
    Logger.debug("User #{key} online? -> #{is_online}")

    is_online
  end


  defp update_message_status(message_id, user_id, new_status) do
    existing = Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

    cond do
      existing == nil ->
        %MessageStatus{}
        |> MessageStatus.changeset(%{
          "message_id" => message_id,
          "user_id" => user_id,
          "status" => new_status
        })
        |> Repo.insert()

      true ->
        if status_value(new_status) > status_value(existing.status) do
          existing
          |> MessageStatus.changeset(%{"status" => new_status})
          |> Repo.update()
        else
          {:ok, existing}
        end
    end
  end

  # defp status_value("sent"), do: 1
  # defp status_value("delivered"), do: 2
  # defp status_value("read"), do: 3
  # defp status_value(_), do: 0


  defp format_errors(changeset),
  do: Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end)

  # defp format_errors(changeset),
    # do: Ecto.Changeset.traverse_errors(changeset, & &1)

  defp status_value("sent"), do: 1
  defp status_value("delivered"), do: 2
  defp status_value("read"), do: 3
  defp status_value(_), do: 0
end
