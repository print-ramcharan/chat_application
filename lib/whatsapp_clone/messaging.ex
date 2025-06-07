# defmodule WhatsappClone.Messaging do
#   @moduledoc """
#   The Messaging context: handles sending/listing messages, attachments, and statuses.
#   """

#   import Ecto.Query, warn: false
#   alias WhatsappClone.{Repo, Message, MessageStatus, Attachment, Conversation, ConversationMember}

#   ##
#   ## MESSAGES
#   ##

#   @doc """
#   Lists all messages for a conversation (with optional pagination).
#   Returns list of messages. Could preload attachments and statuses if desired.
#   """
#   def list_messages(conversation_id) do
#     Message
#     |> where([m], m.conversation_id == ^conversation_id)
#     |> order_by([m], asc: m.inserted_at)
#     |> Repo.all()
#     |> Repo.preload([:attachments, :status_entries])
#   end

#   @doc """
#   Creates a new message in a conversation with `sender_id` + `message_params`.
#   Expects params like:
#       %{"encrypted_body" => "...", "message_type" => "text" | "image" | ...}
#   Returns {:ok, %Message{}} or {:error, changeset}.
#   """
#   def create_message(conversation_id, sender_id, %{
#         "encrypted_body" => encrypted_body,
#         "message_type" => message_type
#       } = _params) do
#     # Verify sender belongs to the conversation
#     if user_in_conversation?(sender_id, conversation_id) do
#       attrs = %{
#         "sender_id" => sender_id,
#         "conversation_id" => conversation_id,
#         "encrypted_body" => encrypted_body,
#         "message_type" => message_type
#       }

#       %Message{}
#       |> Message.changeset(attrs)
#       |> Repo.insert()
#       |> case do
#         {:ok, msg} ->
#           # Create an initial status for the sender (sent)
#           %MessageStatus{}
#           |> MessageStatus.changeset(%{
#             "message_id" => msg.id,
#             "user_id" => sender_id,
#             "status" => "sent"
#           })
#           |> Repo.insert()

#           {:ok, msg}

#         error ->
#           error
#       end
#     else
#       {:error, :unauthorized}
#     end
#   end

#   ##
#   ## MESSAGE STATUSES
#   ##

#   @doc """
#   Updates a message_status for a given user_id + message_id to new_status.
#   Returns {:ok, %MessageStatus{}} or {:error, reason}.
#   """
#   def update_message_status(message_id, user_id, new_status) do
#     # Only allow if user is a member of the conversation
#     with %Message{} = msg <- Repo.get(Message, message_id),
#          true <- user_in_conversation?(user_id, msg.conversation_id) do
#       existing = Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

#       cond do
#         existing == nil ->
#           %MessageStatus{}
#           |> MessageStatus.changeset(%{
#             "message_id" => message_id,
#             "user_id" => user_id,
#             "status" => new_status
#           })
#           |> Repo.insert()

#         existing.status != new_status and status_value(new_status) > status_value(existing.status) ->
#           existing
#           |> MessageStatus.changeset(%{"status" => new_status})
#           |> Repo.update()

#         true ->
#           {:ok, existing}
#       end
#     else
#       _ -> {:error, :unauthorized}
#     end
#   end

#   defp status_value("sent"), do: 1
#   defp status_value("delivered"), do: 2
#   defp status_value("read"), do: 3
#   defp status_value(_), do: 0

#   ##
#   ## ATTACHMENTS (optional for future)
#   ##

#   @doc """
#   Creates an attachment for a given message.
#   """
#   def create_attachment(message_id, %{"file_url" => file_url, "file_type" => file_type}) do
#     %Attachment{}
#     |> Attachment.changeset(%{"message_id" => message_id, "file_url" => file_url, "file_type" => file_type})
#     |> Repo.insert()
#   end

#   ##
#   ## HELPER: is user in conversation?
#   ##
#   defp user_in_conversation?(user_id, conversation_id) do
#     Repo.get_by(ConversationMember, user_id: user_id, conversation_id: conversation_id) != nil
#   end
# end


# defmodule WhatsappClone.Messaging do
#   import Ecto.Query, warn: false
#   alias WhatsappClone.{Repo, Message, MessageStatus, Attachment, ConversationMember}

#   def list_messages(conversation_id) do
#     Message
#     |> where([m], m.conversation_id == ^conversation_id)
#     |> order_by([m], asc: m.inserted_at)
#     |> Repo.all()
#     |> Repo.preload([:attachments, :status_entries])
#   end

#   def create_message(conversation_id, sender_id, %{
#         "encrypted_body" => encrypted_body,
#         "message_type" => message_type
#       }) do
#     if user_in_conversation?(sender_id, conversation_id) do
#       attrs = %{
#         "sender_id" => sender_id,
#         "conversation_id" => conversation_id,
#         "encrypted_body" => encrypted_body,
#         "message_type" => message_type
#       }

#       case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#         {:ok, msg} ->
#           %MessageStatus{}
#           |> MessageStatus.changeset(%{
#             "message_id" => msg.id,
#             "user_id" => sender_id,
#             "status" => "sent"
#           })
#           |> Repo.insert()

#           {:ok, msg}

#         error -> error
#       end
#     else
#       {:error, :unauthorized}
#     end
#   end

#   def create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
#     if user_in_conversation?(sender_id, conversation_id) do
#       Repo.transaction(fn ->
#         {:ok, message} =
#           %Message{}
#           |> Message.changeset(Map.merge(message_params, %{
#             "sender_id" => sender_id,
#             "conversation_id" => conversation_id
#           }))
#           |> Repo.insert()

#         Enum.each(attachments, fn attachment ->
#           # Convert string keys to atom keys safely
#           atomized = for {k, v} <- attachment, into: %{}, do: {String.to_existing_atom(k), v}
#           create_attachment(message.id, atomized)
#         end)

#         message
#       end)
#     else
#       {:error, :unauthorized}
#     end
#   end

#   def create_message_with_attachments(conversation_id, sender_id, message_params, attachments_params) do
#     if user_in_conversation?(sender_id, conversation_id) do
#       Repo.transaction(fn ->
#         # Create message
#         case %Message{} |> Message.changeset(Map.merge(message_params, %{
#                "sender_id" => sender_id,
#                "conversation_id" => conversation_id
#              })) |> Repo.insert() do
#           {:ok, msg} ->
#             # Insert attachments if any
#             Enum.each(attachments_params, fn att ->
#               create_attachment(msg.id, att)
#             end)

#             # Create initial message status
#             %MessageStatus{}
#             |> MessageStatus.changeset(%{
#               "message_id" => msg.id,
#               "user_id" => sender_id,
#               "status" => "sent"
#             })
#             |> Repo.insert()

#             msg

#           {:error, changeset} ->
#             Repo.rollback(changeset)
#         end
#       end)
#     else
#       {:error, :unauthorized}
#     end
#   end
#   def get_message_with_details(id) do
#     Repo.get(Message, id)
#     |> Repo.preload([:attachments, :status_entries])
#   end
#   def update_message_status(message_id, user_id, new_status) do
#     with %Message{} = msg <- Repo.get(Message, message_id),
#          true <- user_in_conversation?(user_id, msg.conversation_id) do
#       existing = Repo.get_by(MessageStatus, message_id: message_id, user_id: user_id)

#       cond do
#         existing == nil ->
#           %MessageStatus{}
#           |> MessageStatus.changeset(%{
#             "message_id" => message_id,
#             "user_id" => user_id,
#             "status" => new_status
#           })
#           |> Repo.insert()

#         existing.status != new_status and status_value(new_status) > status_value(existing.status) ->
#           existing
#           |> MessageStatus.changeset(%{"status" => new_status})
#           |> Repo.update()

#         true ->
#           {:ok, existing}
#       end
#     else
#       _ -> {:error, :unauthorized}
#     end
#   end

#   defp status_value("sent"), do: 1
#   defp status_value("delivered"), do: 2
#   defp status_value("read"), do: 3
#   defp status_value(_), do: 0

#   def create_attachment(message_id, %{"file_url" => file_url, "file_type" => file_type}) do
#     %Attachment{}
#     |> Attachment.changeset(%{"message_id" => message_id, "file_url" => file_url, "file_type" => file_type})
#     |> Repo.insert()
#   end

#   defp user_in_conversation?(user_id, conversation_id) do
#     Repo.get_by(ConversationMember, user_id: user_id, conversation_id: conversation_id) != nil
#   end
# end


defmodule WhatsappClone.Messaging do
  import Ecto.Query, warn: false
  alias WhatsappClone.{Repo, Message, MessageStatus, Attachment, ConversationMember}

  def list_messages(conversation_id) do
    Message
    |> where([m], m.conversation_id == ^conversation_id)
    |> order_by([m], asc: m.inserted_at)
    |> Repo.all()
    |> Repo.preload([:attachments, :status_entries])
  end

  def create_message(conversation_id, sender_id, %{
        "encrypted_body" => encrypted_body,
        "message_type" => message_type
      }) do
    if user_in_conversation?(sender_id, conversation_id) do
      attrs = %{
        "sender_id" => sender_id,
        "conversation_id" => conversation_id,
        "encrypted_body" => encrypted_body,
        "message_type" => message_type
      }

      case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
        {:ok, msg} ->
          %MessageStatus{}
          |> MessageStatus.changeset(%{
            "message_id" => msg.id,
            "user_id" => sender_id,
            "status" => "sent"
          })
          |> Repo.insert()

          {:ok, msg}

        error -> error
      end
    else
      {:error, :unauthorized}
    end
  end

  def create_message_with_attachments(conversation_id, sender_id, message_params, attachments) do
    if user_in_conversation?(sender_id, conversation_id) do
      Repo.transaction(fn ->
        case %Message{}
             |> Message.changeset(Map.merge(message_params, %{
               "sender_id" => sender_id,
               "conversation_id" => conversation_id
             }))
             |> Repo.insert() do
          {:ok, msg} ->
            Enum.each(attachments, fn attachment ->
              atomized = for {k, v} <- attachment, into: %{}, do: {String.to_existing_atom(k), v}
              create_attachment(msg.id, atomized)
            end)

            %MessageStatus{}
            |> MessageStatus.changeset(%{
              "message_id" => msg.id,
              "user_id" => sender_id,
              "status" => "sent"
            })
            |> Repo.insert()

            msg

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    else
      {:error, :unauthorized}
    end
  end

  def create_attachment(message_id, %{file_url: file_url, mime_type: mime_type}) do
    %Attachment{}
    |> Attachment.changeset(%{
      "message_id" => message_id,
      "file_url" => file_url,
      "mime_type" => mime_type
    })
    |> Repo.insert()
  end

  def get_message_with_details(id) do
    Repo.get(Message, id)
    |> Repo.preload([:attachments, :status_entries])
  end

  def update_message_status(message_id, user_id, new_status) do
    with %Message{} = msg <- Repo.get(Message, message_id),
         true <- user_in_conversation?(user_id, msg.conversation_id) do
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

        existing.status != new_status and status_value(new_status) > status_value(existing.status) ->
          existing
          |> MessageStatus.changeset(%{"status" => new_status})
          |> Repo.update()

        true ->
          {:ok, existing}
      end
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp status_value("sent"), do: 1
  defp status_value("delivered"), do: 2
  defp status_value("read"), do: 3
  defp status_value(_), do: 0

  defp user_in_conversation?(user_id, conversation_id) do
    Repo.get_by(ConversationMember, user_id: user_id, conversation_id: conversation_id) != nil
  end
end
