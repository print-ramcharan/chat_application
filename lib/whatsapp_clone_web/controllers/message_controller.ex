# defmodule WhatsappCloneWeb.MessageController do
#   use WhatsappCloneWeb, :controller

#   alias WhatsappClone.Messaging

#   action_fallback WhatsappCloneWeb.FallbackController

#   @doc """
#   POST /api/conversations/:conversation_id/messages
#   Body params: %{"encrypted_body" => "...", "message_type" => "..."}
#   Requires `conn.assigns.user_id` to be the sender.
#   """
#   # def create(conn, %{"conversation_id" => conversation_id} = params) do
#   #   sender_id = conn.assigns[:user_id]
#   #   message_params = Map.take(params, ["encrypted_body", "message_type"])

#   #   case Messaging.create_message(conversation_id, sender_id, message_params) do
#   #     {:ok, message} ->
#   #       json(conn, %{
#   #         message: %{
#   #           id: message.id,
#   #           sender_id: message.sender_id,
#   #           encrypted_body: message.encrypted_body,
#   #           message_type: message.message_type,
#   #           inserted_at: message.inserted_at
#   #         }
#   #       })

#   #     {:error, :unauthorized} ->
#   #       conn
#   #       |> put_status(:forbidden)
#   #       |> json(%{error: "Not a member of this conversation"})

#   #     {:error, changeset} ->
#   #       conn
#   #       |> put_status(:unprocessable_entity)
#   #       |> json(%{errors: render_changeset_errors(changeset)})
#   #   end
#   # end



#   def create(conn, %{"conversation_id" => conversation_id} = params) do
#     sender_id = conn.assigns[:user_id]

#     # Extract message params
#     message_params = Map.take(params, ["encrypted_body", "message_type"])

#     # Extract attachments param if any, default to empty list
#     attachments = Map.get(params, "attachments", [])

#     case Messaging.create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#       {:ok, message} ->
#         message = Repo.preload(message, [:attachments, :status_entries])

#         json(conn, %{
#           message: %{
#             id: message.id,
#             sender_id: message.sender_id,
#             encrypted_body: message.encrypted_body,
#             message_type: message.message_type,
#             inserted_at: message.inserted_at,
#             attachments: Enum.map(message.attachments, fn att ->
#               %{
#                 id: att.id,
#                 file_url: att.file_url,
#                 file_type: att.file_type
#               }
#             end)
#             # Optionally include status entries here
#           }
#         })

#       {:error, :unauthorized} ->
#         conn
#         |> put_status(:forbidden)
#         |> json(%{error: "Not a member of this conversation"})

#       {:error, changeset} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: render_changeset_errors(changeset)})
#     end
#   end


#   @doc """
#   GET /api/conversations/:conversation_id/messages
#   Returns all messages (and attachments/status if you like) for a conversation.
#   """
#   def index(conn, %{"conversation_id" => conversation_id}) do
#     messages = Messaging.list_messages(conversation_id)
#     json(conn, %{messages: messages})
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end

# defmodule WhatsappCloneWeb.MessageController do
#   use WhatsappCloneWeb, :controller

#   alias WhatsappClone.{Messaging, Repo, Message}

#   action_fallback WhatsappCloneWeb.FallbackController

#   @doc """
#   POST /api/conversations/:conversation_id/messages
#   Body params: %{"encrypted_body" => "...", "message_type" => "...", "attachments" => [...]}
#   Requires `conn.assigns.user_id` to be the sender.
#   """
#   # def create(conn, %{"conversation_id" => conversation_id} = params) do
#   #   sender_id = conn.assigns[:user_id]

#   #   message_params = Map.take(params, ["encrypted_body", "message_type"])
#   #   attachments = Map.get(params, "attachments", [])

#   #   case Messaging.create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#   #     {:ok, message} ->
#   #       message = Messaging.get_message_with_details(message.id)

#   #       json(conn, %{
#   #         message: %{
#   #           id: message.id,
#   #           sender_id: message.sender_id,
#   #           encrypted_body: message.encrypted_body,
#   #           message_type: message.message_type,
#   #           inserted_at: message.inserted_at,
#   #           attachments: Enum.map(message.attachments, fn att ->
#   #             %{
#   #               id: att.id,
#   #               file_url: att.file_url,
#   #               file_type: att.mime_type
#   #             }
#   #           end)
#   #         }
#   #       })

#   #     {:error, :unauthorized} ->
#   #       conn
#   #       |> put_status(:forbidden)
#   #       |> json(%{error: "Not a member of this conversation"})

#   #     {:error, changeset} ->
#   #       conn
#   #       |> put_status(:unprocessable_entity)
#   #       |> json(%{errors: render_changeset_errors(changeset)})
#   #   end
#   # end

#   # def create(conn, %{"conversation_id" => conversation_id} = params) do
#   #   sender_id = conn.assigns[:user_id]

#   #   message_params = Map.take(params, ["encrypted_body", "message_type"])
#   #   attachments = Map.get(params, "attachments", [])

#   #   case Messaging.create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#   #     {:ok, message} ->
#   #       message = Messaging.get_message_with_details(message.id)

#   #       json(conn, %{
#   #         message: %{
#   #           id: message.id,
#   #           sender_id: message.sender_id,
#   #           encrypted_body: message.encrypted_body,
#   #           message_type: message.message_type,
#   #           inserted_at: message.inserted_at,
#   #           attachments: Enum.map(message.attachments, fn att ->
#   #             %{
#   #               id: att.id,
#   #               file_url: att.file_url,
#   #               mime_type: att.mime_type
#   #             }
#   #           end)
#   #         }
#   #       })

#   #     {:error, :unauthorized} ->
#   #       conn
#   #       |> put_status(:forbidden)
#   #       |> json(%{error: "Not a member of this conversation"})

#   #     {:error, changeset} ->
#   #       conn
#   #       |> put_status(:unprocessable_entity)
#   #       |> json(%{errors: render_changeset_errors(changeset)})
#   #   end
#   # end

#   def create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#     Repo.transaction(fn ->
#       # 1. Insert message
#       {:ok, message} =
#         %Message{}
#         |> Message.changeset(Map.merge(message_params, %{
#              conversation_id: conversation_id,
#              sender_id: sender_id
#            }))
#         |> Repo.insert()

#       # 2. Insert attachments if any
#       Enum.each(attachments, fn att_params ->
#         # Insert each attachment with message_id = message.id
#         %Attachment{}
#         |> Attachment.changeset(Map.put(att_params, "message_id", message.id))
#         |> Repo.insert!()
#       end)

#       # 3. Fetch conversation members except sender
#       members =
#         from(cm in ConversationMember,
#           where: cm.conversation_id == ^conversation_id and cm.user_id != ^sender_id,
#           select: cm.user_id
#         )
#         |> Repo.all()

#       # 4. Insert message_statuses for each member
#       now = DateTime.utc_now()

#       message_statuses = Enum.map(members, fn user_id ->
#         %{
#           message_id: message.id,
#           user_id: user_id,
#           status: "sent",
#           status_ts: now,
#           inserted_at: now,
#           updated_at: now
#         }
#       end)

#       Repo.insert_all("message_statuses", message_statuses)

#       message
#     end)
#   end


#   @doc """
#   GET /api/conversations/:conversation_id/messages
#   Returns all messages with attachments and statuses for a conversation.
#   """
#   def index(conn, %{"conversation_id" => conversation_id}) do
#     messages = Messaging.list_messages(conversation_id)
#     json(conn, %{messages: messages})
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end

# defmodule WhatsappCloneWeb.MessageController do
#   use WhatsappCloneWeb, :controller

#   import Ecto.Query


#   alias WhatsappClone.{Messaging, Repo, Message, Attachment, ConversationMember}

#   action_fallback WhatsappCloneWeb.FallbackController

#   @doc """
#   POST /api/conversations/:conversation_id/messages
#   Body params: %{"encrypted_body" => "...", "message_type" => "...", "attachments" => [...]}
#   Requires `conn.assigns.user_id` to be the sender.
#   """
#   def create(conn, %{"conversation_id" => conversation_id} = params) do
#     sender_id = conn.assigns[:user_id]

#     message_params = Map.take(params, ["encrypted_body", "message_type"])
#     attachments = Map.get(params, "attachments", [])

#     case create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#       {:ok, message} ->
#         message = Messaging.get_message_with_details(message.id)

#         json(conn, %{
#           message: %{
#             id: message.id,
#             sender_id: message.sender_id,
#             encrypted_body: message.encrypted_body,
#             message_type: message.message_type,
#             inserted_at: message.inserted_at,
#             attachments: Enum.map(message.attachments, fn att ->
#               %{
#                 id: att.id,
#                 file_url: att.file_url,
#                 mime_type: att.mime_type
#               }
#             end)
#           }
#         })

#       {:error, :unauthorized} ->
#         conn
#         |> put_status(:forbidden)
#         |> json(%{error: "Not a member of this conversation"})

#       {:error, changeset} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: render_changeset_errors(changeset)})
#     end
#   end

#   defp create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#     Repo.transaction(fn ->
#       # 1. Insert message
#       {:ok, message} =
#         %Message{}
#         |> Message.changeset(Map.merge(message_params, %{
#           "conversation_id" => conversation_id,
#           "sender_id" => sender_id
#         }))
#         |> Repo.insert()

#       # 2. Insert attachments if any
#       Enum.each(attachments, fn att_params ->
#         %Attachment{}
#         |> Attachment.changeset(Map.put(att_params, "message_id", message.id))
#         |> Repo.insert!()
#       end)

#       # 3. Fetch conversation members except sender
#       members =
#         from(cm in ConversationMember,
#           where: cm.conversation_id == ^conversation_id and cm.user_id != ^sender_id,
#           select: cm.user_id
#         )
#         |> Repo.all()

#       # 4. Insert message_statuses for each member
#       now = DateTime.utc_now()

#       message_statuses = Enum.map(members, fn user_id ->
#         {:ok, user_id_bin} = Ecto.UUID.dump(user_id)
#         {:ok, message_id_bin} = Ecto.UUID.dump(message.id)

#         %{
#           message_id: message_id_bin,
#           user_id: user_id_bin,
#           status: "sent",
#           status_ts: now,
#           inserted_at: now,
#           updated_at: now
#         }
#       end)

#       Repo.insert_all("message_statuses", message_statuses)

#       {:ok, message}
#     end)
#   end

#   @doc """
#   GET /api/conversations/:conversation_id/messages
#   Returns all messages with attachments and statuses for a conversation.
#   """
#   def index(conn, %{"conversation_id" => conversation_id}) do
#     messages = Messaging.list_messages(conversation_id)
#     json(conn, %{messages: messages})
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end

# defmodule WhatsappCloneWeb.MessageController do
#   use WhatsappCloneWeb, :controller

#   import Ecto.Query

#   alias WhatsappClone.{Messaging, Repo, Message, Attachment, ConversationMember}

#   action_fallback WhatsappCloneWeb.FallbackController

#   @doc """
#   POST /api/conversations/:conversation_id/messages
#   Body params: %{"encrypted_body" => "...", "message_type" => "...", "attachments" => [...]}
#   Requires `conn.assigns.user_id` to be the sender.
#   """
#   def create(conn, %{"conversation_id" => conversation_id} = params) do
#     sender_id = conn.assigns[:user_id]

#     message_params = Map.take(params, ["encrypted_body", "message_type"])
#     attachments = Map.get(params, "attachments", [])

#     case create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#       {:ok, message} ->
#         message = Messaging.get_message_with_details(message.id)

#         json(conn, %{
#           message: %{
#             id: message.id,
#             sender_id: message.sender_id,
#             encrypted_body: message.encrypted_body,
#             message_type: message.message_type,
#             inserted_at: message.inserted_at,
#             attachments: Enum.map(message.attachments, fn att ->
#               %{
#                 id: att.id,
#                 file_url: att.file_url,
#                 mime_type: att.mime_type
#               }
#             end)
#           }
#         })

#       {:error, :unauthorized} ->
#         conn
#         |> put_status(:forbidden)
#         |> json(%{error: "Not a member of this conversation"})

#       {:error, changeset} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: render_changeset_errors(changeset)})
#     end
#   end

#   defp create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#     Repo.transaction(fn ->
#       # 1. Insert message
#       {:ok, message} =
#         %Message{}
#         |> Message.changeset(Map.merge(message_params, %{
#           "conversation_id" => conversation_id,
#           "sender_id" => sender_id
#         }))
#         |> Repo.insert()

#       # 2. Insert attachments if any
#       Enum.each(attachments, fn att_params ->
#         %Attachment{}
#         |> Attachment.changeset(Map.put(att_params, "message_id", message.id))
#         |> Repo.insert!()
#       end)

#       # 3. Fetch conversation members except sender
#       members =
#         from(cm in ConversationMember,
#           where: cm.conversation_id == ^conversation_id and cm.user_id != ^sender_id,
#           select: cm.user_id
#         )
#         |> Repo.all()

#       # 4. Insert message_statuses for each member
#       now = DateTime.utc_now()

#       message_statuses = Enum.map(members, fn user_id ->
#         %{
#           message_id: to_uuid_bin(message.id),
#           user_id: to_uuid_bin(user_id),
#           status: "sent",
#           status_ts: now,
#           inserted_at: now,
#           updated_at: now
#         }
#       end)

#       Repo.insert_all("message_statuses", message_statuses)

#       {:ok, message}
#     end)
#   end

#   defp to_uuid_bin(uuid_str) do
#     case Ecto.UUID.dump(uuid_str) do
#       {:ok, bin} -> bin
#       :error -> raise ArgumentError, "Invalid UUID: #{uuid_str}"
#     end
#   end

#   @doc """
#   GET /api/conversations/:conversation_id/messages
#   Returns all messages with attachments and statuses for a conversation.
#   """
#   def index(conn, %{"conversation_id" => conversation_id}) do
#     messages = Messaging.list_messages(conversation_id)
#     json(conn, %{messages: messages})
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end
# defmodule WhatsappCloneWeb.MessageController do
#   use WhatsappCloneWeb, :controller

#   import Ecto.Query

#   alias WhatsappClone.{Messaging, Repo, Message, Attachment, ConversationMember}

#   action_fallback WhatsappCloneWeb.FallbackController

#   def create(conn, %{
#     "conversation_id" => conversation_id,
#     "encrypted_body" => encrypted_body,
#     "message_type" => message_type
#   } = params) do
#     sender_id = conn.assigns[:user_id]
#     attachments = Map.get(params, "attachments", [])

#     case create_message_with_attachments(conversation_id, sender_id, %{
#       "encrypted_body" => encrypted_body,
#       "message_type" => message_type
#     }, attachments) do
#       {:ok, message} ->
#         message = Repo.preload(message, :attachments)

#         json(conn, %{
#           status: "success",
#           message: %{
#             id: message.id,
#             conversation_id: message.conversation_id,
#             sender_id: message.sender_id,
#             encrypted_body: message.encrypted_body,
#             message_type: message.message_type,
#             inserted_at: message.inserted_at,
#             attachments: Enum.map(message.attachments, fn att ->
#               %{
#                 id: att.id,
#                 file_url: att.file_url,
#                 mime_type: att.mime_type,
#                 file_size: att.file_size || nil  # Handle nil case
#               }
#             end)
#           }
#         })

#       {:error, reason} ->
#         conn
#         |> put_status(:bad_request)
#         |> json(%{status: "error", reason: inspect(reason)})
#     end
#   end

#   defp create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#     attachments = attachments || []

#     Repo.transaction(fn ->
#       {:ok, message} =
#         %Message{}
#         |> Message.changeset(Map.merge(message_params, %{
#           "conversation_id" => conversation_id,
#           "sender_id" => sender_id
#         }))
#         |> Repo.insert()

#       Enum.each(attachments, fn att_params ->
#         %Attachment{}
#         |> Attachment.changeset(Map.merge(att_params, %{
#           "message_id" => message.id,
#           "file_size" => att_params["file_size"] || nil  # Ensure file_size is included
#         }))
#         |> Repo.insert!()
#       end)

#       members =
#         from(cm in ConversationMember,
#           where: cm.conversation_id == ^conversation_id and cm.user_id != ^sender_id,
#           select: cm.user_id
#         )
#         |> Repo.all()

#       now = DateTime.utc_now()

#       message_statuses = Enum.map(members, fn user_id ->
#         %{
#           message_id: to_uuid_bin(message.id),
#           user_id: to_uuid_bin(user_id),
#           status: "sent",
#           status_ts: now,
#           inserted_at: now,
#           updated_at: now
#         }
#       end)

#       Repo.insert_all("message_statuses", message_statuses)

#       message
#     end)
#   end

#   defp to_uuid_bin(uuid_str) do
#     case Ecto.UUID.dump(uuid_str) do
#       {:ok, bin} -> bin
#       :error -> raise ArgumentError, "Invalid UUID: #{uuid_str}"
#     end
#   end

#   def index(conn, %{"conversation_id" => conversation_id}) do
#     messages = Messaging.list_messages(conversation_id)
#     json(conn, %{messages: messages})
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end

defmodule WhatsappCloneWeb.MessageController do
  use WhatsappCloneWeb, :controller

  import Ecto.Query

  alias WhatsappClone.{Messaging, Repo, Message, Attachment, ConversationMember}

  action_fallback WhatsappCloneWeb.FallbackController

  def create(conn, %{
    "conversation_id" => conversation_id,
    "encrypted_body" => encrypted_body,
    "message_type" => message_type
  } = params) do
    sender_id = conn.assigns[:user_id]
    attachments = Map.get(params, "attachments", [])

    case create_message_with_attachments(conversation_id, sender_id, %{
      "encrypted_body" => encrypted_body,
      "message_type" => message_type
    }, attachments) do
      {:ok, message} ->
        message = Repo.preload(message, attachments: from(a in Attachment, select: %{
          id: a.id,
          file_url: a.file_url,
          mime_type: a.mime_type,
          file_size: a.file_size
        }))

        json(conn, %{
          status: "success",
          message: %{
            id: message.id,
            conversation_id: message.conversation_id,
            sender_id: message.sender_id,
            encrypted_body: message.encrypted_body,
            message_type: message.message_type,
            inserted_at: message.inserted_at,
            attachments: message.attachments
          }
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", reason: inspect(reason)})
    end
  end

  defp create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
    Repo.transaction(fn ->
      {:ok, message} =
        %Message{}
        |> Message.changeset(Map.merge(message_params, %{
          "conversation_id" => conversation_id,
          "sender_id" => sender_id
        }))
        |> Repo.insert()

      # Handle attachments if they exist
      if attachments != [] do
        Enum.each(attachments, fn att_params ->
          %Attachment{}
          |> Attachment.changeset(%{
            "file_url" => att_params["file_url"],
            "mime_type" => att_params["mime_type"],
            "file_size" => att_params["file_size"],
            "message_id" => message.id
          })
          |> Repo.insert!()
        end)
      end

      # Create message statuses for all members except sender
      members =
        from(cm in ConversationMember,
          where: cm.conversation_id == ^conversation_id and cm.user_id != ^sender_id,
          select: cm.user_id
        )
        |> Repo.all()

      now = DateTime.utc_now()

      message_statuses = Enum.map(members, fn user_id ->
        %{
          message_id: to_uuid_bin(message.id),
          user_id: to_uuid_bin(user_id),
          status: "sent",
          status_ts: now,
          inserted_at: now,
          updated_at: now
        }
      end)

      Repo.insert_all("message_statuses", message_statuses)

      message
    end)
  end

  defp to_uuid_bin(uuid_str) do
    case Ecto.UUID.dump(uuid_str) do
      {:ok, bin} -> bin
      :error -> raise ArgumentError, "Invalid UUID: #{uuid_str}"
    end
  end
  # def reply(conn, %{"message_id" => message_id, "content" => content}) do
  #   user_id = conn.assigns[:user_id]

  #   with {:ok, original} <- fetch_original_message(message_id),
  #        {:ok, _member} <- fetch_conversation_membership(original.conversation_id, user_id),
  #        {:ok, reply_msg} <- WhatsappClone.Messaging.create_reply_message(user_id, original.conversation_id, content, message_id) do

  #     # json(conn, reply_msg)
  #     json(conn, Repo.preload(reply_msg, [:attachments, :status_entries]))

  #   else
  #     {:error, :not_found} ->
  #       conn |> put_status(:not_found) |> json(%{error: "Original message not found"})

  #     {:error, :forbidden} ->
  #       conn |> put_status(:forbidden) |> json(%{error: "User not part of conversation"})

  #     {:error, reason} ->
  #       conn |> put_status(:bad_request) |> json(%{error: inspect(reason)})
  #   end
  # end

  # def reply(conn, %{"message_id" => message_id, "content" => content}) do
  #   user_id = conn.assigns[:user_id]

  #   with {:ok, original} <- fetch_original_message(message_id),
  #        {:ok, _member} <- fetch_conversation_membership(original.conversation_id, user_id),
  #        {:ok, reply_msg} <- WhatsappClone.Messaging.create_reply_message(user_id, original.conversation_id, content, message_id) do

  #     members =
  #       from(cm in WhatsappClone.ConversationMember,
  #         where: cm.conversation_id == ^original.conversation_id,
  #         select: cm.user_id
  #       )
  #       |> Repo.all()

  #     # 1. Broadcast to chat (for users already inside the conversation)
  #     WhatsappCloneWeb.Endpoint.broadcast("chat:#{original.conversation_id}", "new_message", %{
  #       "message_id" => reply_msg.id,
  #       "conversation_id" => original.conversation_id,
  #       "encrypted_body" => reply_msg.encrypted_body,
  #       "message_status" => "sent",
  #       "reply_to" => message_id,
  #       "sender_id" => user_id,
  #       "inserted_at" => reply_msg.inserted_at,
  #       "message_type" => reply_msg.message_type
  #     })

  #     # 2. Broadcast to each user's personal channel (e.g., for unread count updates)
  #     Enum.each(members, fn member_id ->
  #       WhatsappCloneWeb.Endpoint.broadcast("user:#{member_id}", "new_message", %{
  #         "conversation_id" => reply_msg.conversation_id,
  #         "encrypted_body" => reply_msg.encrypted_body,
  #         "message_status" => "sent",
  #         "sender_id" => user_id,
  #         "reply_to" => message_id
  #       })

  #       # Optional:
  #       # Trigger FCM if member_id is offline — you'll need to implement presence tracking + FCM logic
  #       # PushNotifier.send_if_offline(member_id, ...)
  #     end)

  #     # 3. Echo to sender's own user channel (so UI updates like sent tick show immediately)
  #     WhatsappCloneWeb.Endpoint.broadcast("user:#{user_id}", "new_message", %{
  #       "conversation_id" => reply_msg.conversation_id,
  #       "encrypted_body" => reply_msg.encrypted_body,
  #       "message_status" => "sent",
  #       "sender_id" => user_id,
  #       "reply_to" => message_id
  #     })

  #     json(conn, Repo.preload(reply_msg, [:attachments, :status_entries]))
  #   else
  #     {:error, :not_found} ->
  #       conn |> put_status(:not_found) |> json(%{error: "Original message not found"})

  #     {:error, :forbidden} ->
  #       conn |> put_status(:forbidden) |> json(%{error: "User not part of conversation"})

  #     {:error, reason} ->
  #       conn |> put_status(:bad_request) |> json(%{error: inspect(reason)})
  #   end
  # end

  def reply(conn, %{"message_id" => message_id, "content" => content}) do
    user_id = conn.assigns[:user_id]

    with {:ok, original} <- fetch_original_message(message_id),
         {:ok, _member} <- fetch_conversation_membership(original.conversation_id, user_id),
         {:ok, reply_msg} <- WhatsappClone.Messaging.create_reply_message(user_id, original.conversation_id, content, message_id) do

      # Fetch all conversation members
      members =
        from(cm in WhatsappClone.ConversationMember,
          where: cm.conversation_id == ^original.conversation_id,
          select: cm.user_id
        )
        |> Repo.all()

      # Compute statuses for each member
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      status_entries =
        Enum.map(members, fn member_id ->
          status =
            cond do
              member_id == user_id ->
                "sent"

              WhatsappClone.PresenceTracker.online_in_conversation?(member_id, original.conversation_id) ->
                "read"

              WhatsappClone.PresenceTracker.online_in_personal_channel?(member_id) ->
                "delivered"

              true ->
                "sent"
            end

          %{
            message_id: reply_msg.id,
            user_id: member_id,
            status: status,
            inserted_at: timestamp,
            updated_at: timestamp
          }
        end)

      # Insert all statuses into the DB
      Repo.insert_all(WhatsappClone.MessageStatus, status_entries)

      # Preload the statuses so we can build the sender's status summary
      reply_msg = Repo.preload(reply_msg, [:attachments, status_entries: [:user]])

      # Build statuses map excluding the sender
      recipient_statuses =
        Enum.reject(reply_msg.status_entries, &(&1.user_id == user_id))

      statuses_for_sender =
        Enum.into(recipient_statuses, %{}, fn s -> {s.user_id, s.status} end)

      # Determine the aggregate status
      aggregate_status =
        cond do
          Enum.all?(recipient_statuses, &(&1.status == "read")) -> "read"
          Enum.any?(recipient_statuses, &(&1.status == "delivered")) -> "delivered"
          true -> "sent"
        end

      # 1️⃣ Broadcast to chat channel (everyone in conversation)
      WhatsappCloneWeb.Endpoint.broadcast("chat:#{original.conversation_id}", "new_message", %{
        "message_id" => reply_msg.id,
        "conversation_id" => reply_msg.conversation_id,
        "encrypted_body" => reply_msg.encrypted_body,
        "sender_id" => user_id,
        "reply_to" => message_id,
        "inserted_at" => reply_msg.inserted_at,
        "message_type" => reply_msg.message_type
      })

      # 2️⃣ Broadcast to each user's personal channel
      Enum.each(members, fn member_id ->
        payload =
          if member_id == user_id do
            %{
              "conversation_id" => reply_msg.conversation_id,
              "encrypted_body" => reply_msg.encrypted_body,
              "statuses" => statuses_for_sender,
              "message_status" => aggregate_status,
              "sender_id" => user_id,
              "reply_to" => message_id
            }
          else
            %{
              "conversation_id" => reply_msg.conversation_id,
              "encrypted_body" => reply_msg.encrypted_body,
              "sender_id" => user_id,
              "reply_to" => message_id
            }
          end

        WhatsappCloneWeb.Endpoint.broadcast("user:#{member_id}", "new_message", payload)
      end)

      # Return HTTP response
      json(conn, reply_msg)
    else
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Original message not found"})

      {:error, :forbidden} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "User not part of conversation"})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: inspect(reason)})
    end
  end






  defp fetch_original_message(message_id) do
    case Repo.get(Message, message_id) do
      nil -> {:error, :not_found}
      msg -> {:ok, msg}
    end
  end

  defp fetch_conversation_membership(conversation_id, user_id) do
    case Repo.get_by(ConversationMember, conversation_id: conversation_id, user_id: user_id) do
      nil -> {:error, :forbidden}
      cm -> {:ok, cm}
    end
  end


  # def index(conn, %{"conversation_id" => conversation_id}) do
  #   WhatsappClone.Messaging.set_last_read_at(conversation_id, user_id)

  #   messages = Messaging.list_messages(conversation_id)

  #   IO.inspect(messages, label: "Messages being returned")

  #   # json(conn, %{messages: messages})
  #   render(conn, WhatsappCloneWeb.MessageView, "index.json", messages: messages)

  # end
  def index(conn, %{"conversation_id" => conversation_id}) do
    user_id = conn.assigns[:user_id]
    now = DateTime.utc_now()

    # Mark messages as read
    WhatsappClone.Messaging.mark_conversation_read(conversation_id, user_id, now)

    messages = WhatsappClone.Messaging.list_messages(conversation_id)

    render(conn, WhatsappCloneWeb.MessageView, "index.json", messages: messages)
  end


end
