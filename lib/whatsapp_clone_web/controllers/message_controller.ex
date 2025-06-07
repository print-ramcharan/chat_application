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

  def index(conn, %{"conversation_id" => conversation_id}) do
    messages = Messaging.list_messages(conversation_id)
    json(conn, %{messages: messages})
  end
end
