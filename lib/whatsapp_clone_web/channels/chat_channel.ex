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

  defp fetch_assign(socket, key) do
    case Map.fetch(socket.assigns, key) do
      :error -> {:error, :missing}
      ok -> ok
    end
  end

# def handle_in("send_message", %{"encrypted_body" => body, "message_type" => type, "client_ref" => client_ref, "attachment" => attachment_data, "reply_to_id" => reply_to_id}, socket) do

# user_id = socket.assigns.user_id
# conversation_id = socket.assigns.conversation_id

# # Build attributes map with optional reply_to_id
# attrs =
#   %{
#     "sender_id" => user_id,
#     "conversation_id" => conversation_id,
#     "encrypted_body" => body || "",
#     "message_type" => type || "media",
#     "client_ref" => client_ref
#   }
#   |> maybe_put_reply_to(reply_to_id)

# case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
#   {:ok, message} ->
#     timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

#     member_ids =
#       Repo.all(
#         from cm in ConversationMember,
#         where: cm.conversation_id == ^conversation_id,
#         select: cm.user_id
#       )

#     # Insert attachment if provided
#     if attachment_data do
#       changeset_attachment = %WhatsappClone.Attachment{
#         message_id: message.id,
#         file_data: Base.decode64!(attachment_data["file_data"], ignore: :whitespace),
#         mime_type: attachment_data["mime_type"],
#         file_size: attachment_data["file_size"]
#       }

#       case Repo.insert(changeset_attachment) do
#         {:ok, attachment} ->
#           Logger.debug("Attachment saved with ID: #{attachment.id}")

#         {:error, changeset} ->
#           Logger.error("Error saving attachment: #{inspect(changeset.errors)}")
#       end
#     end

#     # Insert status entries for all members
#     Enum.each(member_ids, fn member_id ->
#       Repo.insert!(%MessageStatus{
#         message_id: message.id,
#         user_id: member_id,
#         status: "sent",
#         inserted_at: timestamp,
#         updated_at: timestamp
#       })
#     end)

#     # Preload all associations including nested reply_to
#     preloaded_message =
#       Repo.preload(message, [
#         :attachments,
#         :sender,
#         reply_to: [:sender, :attachments],
#         status_entries: [:user]
#       ])

#     # Render message
#     rendered_msg =
#       Phoenix.View.render(
#         WhatsappCloneWeb.MessageView,
#         "message.json",
#         %{message: preloaded_message}
#       )

#     # Broadcast to all participants
#     send_message_with_statuses_and_attachment(socket, rendered_msg, member_ids)

#     {:reply, {:ok, %{message: rendered_msg}}, socket}

#   {:error, changeset} ->
#     {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
# end
# end
# def handle_in("send_message", %{
#   "encrypted_body" => body,
#   "message_type" => type,
#   "client_ref" => client_ref
# } = payload, socket) do
#   user_id = socket.assigns.user_id
#   conversation_id = socket.assigns.conversation_id

#   attachment_data = Map.get(payload, "attachment")
#   reply_to_id = Map.get(payload, "reply_to")

#   attrs =
#     %{
#       "sender_id" => user_id,
#       "conversation_id" => conversation_id,
#       "encrypted_body" => body || "",
#       "message_type" => type || "media",
#       "client_ref" => client_ref
#     }
#     |> maybe_put_reply_to(reply_to_id)

#   case Message.changeset(%Message{}, attrs) |> Repo.insert() do
#     {:ok, message} ->
#       Logger.debug("✅ Message inserted: #{message.id}")

#       maybe_insert_attachment(message.id, attachment_data)

#       timestamp =
#         DateTime.utc_now()
#         |> DateTime.truncate(:microsecond)  # Ensures microsecond precision

#       naive_ts =
#         timestamp
#         |> DateTime.to_naive()
#         |> NaiveDateTime.truncate(:second)


#       member_ids =
#         Repo.all(from cm in ConversationMember,
#                  where: cm.conversation_id == ^conversation_id,
#                  select: cm.user_id)

#       Enum.each(member_ids, fn member_id ->
#         Repo.insert!(%MessageStatus{
#           message_id: message.id,
#           user_id: member_id,
#           status: "sent",
#           status_ts: timestamp,
#           inserted_at: naive_ts,
#           updated_at: naive_ts
#         })
#       end)

#       preloaded =
#         Repo.preload(message, [
#           :attachments,
#           :sender,
#           :reply_to,
#           reply_to: [:sender, :attachments],
#           status_entries: [:user]
#         ])

#       rendered_msg =
#         Phoenix.View.render(WhatsappCloneWeb.MessageView, "message.json", %{
#           message: preloaded
#         })

#       send_message_with_statuses_and_attachment(socket, rendered_msg, member_ids)
#       {:reply, {:ok, %{message: rendered_msg}}, socket}

#     {:error, changeset} ->
#       Logger.error("❌ Message insert error: #{inspect(changeset.errors)}")
#       {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
#   end
# end


# defp maybe_put_reply_to(attrs, nil), do: attrs
# defp maybe_put_reply_to(attrs, ""), do: attrs
# defp maybe_put_reply_to(attrs, reply_id), do: Map.put(attrs, "reply_to_id", reply_id)

# defp maybe_insert_attachment(_message_id, nil), do: :ok

# defp maybe_insert_attachment(message_id, %{"file_data" => file_data} = data) do
#   Logger.debug("📎 Attachment received: #{inspect(data)}")

#   with {:ok, decoded} <- Base.decode64(file_data, ignore: :whitespace) do
#     changeset =
#       WhatsappClone.Attachment.changeset(%WhatsappClone.Attachment{}, %{
#         message_id: message_id,
#         file_data: decoded,
#         mime_type: data["mime_type"],
#         file_size: data["file_size"]
#       })

#     case Repo.insert(changeset) do
#       {:ok, attachment} ->
#         Logger.debug("✅ Attachment inserted into DB: #{attachment.id}")
#         :ok

#       {:error, err_changeset} ->
#         Logger.error("❌ Attachment insert failed: #{inspect(err_changeset.errors)}")
#         :error
#     end
#   else
#     _ -> Logger.error("❌ Failed to decode Base64 data for attachment"); :error
#   end
# end

def handle_in("send_message", %{ "encrypted_body" => body, "message_type" => type, "client_ref" => client_ref} = payload, socket) do
user_id = socket.assigns.user_id
conversation_id = socket.assigns.conversation_id

attachment_data = Map.get(payload, "attachment")
reply_to_id = Map.get(payload, "reply_to")

# 1. Check for duplicate by client_ref to avoid duplication
existing =
Repo.get_by(Message, conversation_id: conversation_id, client_ref: client_ref)

if existing do
Logger.debug("🟡 Duplicate message ignored (client_ref = #{client_ref})")

# Reply with existing message id to avoid client re-sending
{:reply, {:ok, %{message_id: existing.id}}, socket}
else
# 2. Prepare message attrs including reply_to if any
attrs =
  %{
    "sender_id" => user_id,
    "conversation_id" => conversation_id,
    "encrypted_body" => body || "",
    "message_type" => type || "media",
    "client_ref" => client_ref
  }
  |> maybe_put_reply_to(reply_to_id)

case Repo.insert(Message.changeset(%Message{}, attrs)) do
  {:ok, message} ->
    Logger.debug("✅ Message inserted: #{message.id}")

    # 3. Insert attachment if present
    maybe_insert_attachment(message.id, attachment_data)

    # 4. Prepare timestamps for statuses
    timestamp = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    naive = timestamp |> DateTime.to_naive() |> NaiveDateTime.truncate(:second)

    # 5. Fetch conversation member IDs
    member_ids =
      Repo.all(from cm in ConversationMember,
        where: cm.conversation_id == ^conversation_id,
        select: cm.user_id
      )

    # 6. Online users in chat topic and general online check
    chat_online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()

    user_online_ids =
      member_ids
      |> Enum.map(&if is_user_online?(&1), do: &1)
      |> Enum.reject(&is_nil/1)

    # 7. Insert statuses for all members
    statuses =
      Enum.map(member_ids, fn id ->
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

    # 8. Preload full message info including attachments and reply_to nested info
    full_msg =
      Repo.preload(message, [
        :attachments,
        :sender,
        :reply_to,
        reply_to: [:sender, :attachments],
        status_entries: [:user]
      ])

    # 9. Render full message JSON for broadcasting
    rendered_msg =
      Phoenix.View.render(WhatsappCloneWeb.MessageView, "message.json", %{
        message: full_msg
      })

    # 10. Broadcast full message to chat topic (all except sender)
    broadcast_from!(socket, "new_message", rendered_msg)

    # 11. Also broadcast minimal updates including message status to each user
    # Fetch sender info once for FCM and user broadcasts
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

    # Build a user map for status user info
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

    # Merge statuses with user info for sending to sender as part of reply
    statuses_with_user =
      Enum.map(statuses, fn s ->
        Map.merge(s, Map.get(user_map, s.user_id) || %{})
      end)

    # Broadcast minimal message + status to each user individually (excluding sender)
    member_ids
    |> Enum.reject(&(&1 == user_id))
    |> Enum.each(fn id ->
      # Get statuses for all other members except sender
      other_statuses = Enum.filter(statuses, fn s -> s.user_id != user_id end)

      combined_status =
        cond do
          Enum.all?(other_statuses, &(&1.status == "read")) -> "read"
          Enum.any?(other_statuses, &(&1.status == "delivered")) -> "delivered"
          true -> "sent"
        end

      # 13. Send status update only to sender (not full message)
      push(socket, "message_status_update", %{
        message_id: message.id,
        statuses: statuses_with_user
      })

      # Build minimal broadcast payload
      broadcast_payload = %{
        conversation_id: conversation_id,
        message_id: message.id,
        encrypted_body: body,
        message_type: type,
        sender_id: user_id,
        inserted_at: message.inserted_at,
        client_ref: client_ref,
        message_status: combined_status,
        sender_display_name: sender_user.display_name,
        sender_avatar_data: sender_user.avatar_data
      }

      Endpoint.broadcast("user:#{id}", "new_message", broadcast_payload)

      # 12. Send FCM push notification to offline users (not in chat_online_ids)
      unless id in chat_online_ids do
        fcm_token =
          Repo.one(
            from u in WhatsappClone.User,
            where: u.id == ^id,
            select: u.fcm_token
          )

        if fcm_token do
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
    end)

    # 13. Reply to sender with full message and statuses (including user info)
    {:reply, {:ok, %{message: rendered_msg, statuses: statuses_with_user}}, socket}

  {:error, changeset} ->
    Logger.error("❌ Message insert error: #{inspect(changeset.errors)}")
    {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
end
end
end

defp maybe_put_reply_to(attrs, nil), do: attrs
defp maybe_put_reply_to(attrs, ""), do: attrs
defp maybe_put_reply_to(attrs, reply_id), do: Map.put(attrs, "reply_to_id", reply_id)

defp maybe_insert_attachment(_message_id, nil), do: :ok

defp maybe_insert_attachment(message_id, %{"file_data" => file_data} = data) do
with {:ok, decoded} <- Base.decode64(file_data, ignore: :whitespace) do
changeset =
  WhatsappClone.Attachment.changeset(%WhatsappClone.Attachment{}, %{
    message_id: message_id,
    file_data: decoded,
    mime_type: data["mime_type"],
    file_size: data["file_size"]
  })

case Repo.insert(changeset) do
  {:ok, attachment} ->
    Logger.debug("✅ Attachment inserted: #{attachment.id}")
    :ok

  {:error, changeset} ->
    Logger.error("❌ Attachment insert failed: #{inspect(changeset.errors)}")
    :error
end
else
_ ->
  Logger.error("❌ Base64 decode failed")
  :error
end
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

  #       chat_online_ids = Presence.list("chat:#{conversation_id}") |> Map.keys()
  #       user_online_ids = Enum.map(member_ids, fn id ->
  #         if is_user_online?(id), do: id, else: nil
  #       end) |> Enum.reject(&is_nil/1)


  #       statuses = Enum.map(member_ids, fn id ->
  #         %{
  #           message_id: message.id,
  #           user_id: id,
  #           status: status_for(id, user_id, chat_online_ids, user_online_ids),
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
  #           # Only consider statuses of OTHER members, excluding the sender
  #           other_statuses = Enum.filter(statuses, fn s -> s.user_id != user_id end)

  #           combined_status =
  #             cond do
  #               Enum.all?(other_statuses, &(&1.status == "read")) -> "read"
  #               Enum.any?(other_statuses, &(&1.status == "delivered")) -> "delivered"
  #               true -> "sent"
  #             end

  #           Endpoint.broadcast("user:#{id}", "new_message", %{
  #             conversation_id: conversation_id,
  #             message_id: message.id,
  #             encrypted_body: body,
  #             message_type: type,
  #             sender_id: user_id,
  #             inserted_at: message.inserted_at,
  #             client_ref: client_ref,
  #             message_status: combined_status
  #           })


  #           # 🔥 Add this block here
  #           # unless id in chat_online_ids or id in user_online_ids do
  #             unless id in chat_online_ids do

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



  def handle_in("update_message_status", %{"message_id" => message_id,"user_id" => user_id,"status" => status,"status_ts" => status_ts}, socket) do
    # Forward to your Messages context (expected to handle DB logic)
    WhatsappClone.Messaging.update_message_status(message_id, user_id, status, status_ts)

    broadcast!(socket, "message_status_update", %{
      message_id: message_id,
      user_id: user_id,
      status: status
    })

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
