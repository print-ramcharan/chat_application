defmodule WhatsappCloneWeb.MessageStatusController do
  import Ecto.Query, only: [from: 2]

  use WhatsappCloneWeb, :controller

  alias WhatsappClone.Messaging
  require Logger

  action_fallback WhatsappCloneWeb.FallbackController

  @doc """
  PATCH /api/messages/:message_id/status
  Body params: %{"status" => "delivered" | "read"}
  Requires `conn.assigns.user_id` to be the user updating their own status.
  """
  # def update(conn, %{"message_id" => message_id, "status_code" => new_status}) do
  #   user_id = conn.assigns[:user_id]

  #   case Messaging.update_message_status(message_id, user_id, new_status) do
  #     {:ok, status_entry} ->
  #       json(conn, %{
  #         status: %{
  #           id: status_entry.id,
  #           message_id: status_entry.message_id,
  #           user_id: status_entry.user_id,
  #           status: status_entry.status,
  #           status_ts: status_entry.status_ts
  #         }
  #       })

  #     {:error, :unauthorized} ->
  #       conn
  #       |> put_status(:forbidden)
  #       |> json(%{error: "Not allowed to update this message status"})

  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> json(%{errors: render_changeset_errors(changeset)})
  #   end
  # end

  # def update(conn, %{"message_id" => message_id, "status_code" => new_status}) do
  #   user_id = conn.assigns[:user_id]

  #   case Messaging.update_message_status(message_id, user_id, new_status) do
  #     {:ok, status_entry} ->
  #       message = WhatsappClone.Repo.get!(WhatsappClone.Message, message_id)
  #       sender_id = message.sender_id
  #       conv_id = message.conversation_id

  #       if sender_id != user_id do
  #         # ✅ 1. Broadcast to chat channel for in-chat users
  #         WhatsappCloneWeb.Endpoint.broadcast("chat:#{conv_id}", "message_status_update", %{
  #           message_id: message_id,
  #           user_id: user_id,
  #           status: new_status
  #         })

  #         # ✅ 2. Compute combined status across all recipients (except sender)
  #         status_priority = ["pending", "sent", "delivered", "read"]

  #         other_statuses =
  #           from(ms in WhatsappClone.MessageStatus,
  #             where: ms.message_id == ^message_id and ms.user_id != ^sender_id,
  #             select: ms.status
  #           )
  #           |> WhatsappClone.Repo.all()

  #         combined_status =
  #           Enum.reduce(other_statuses, "read", fn status, acc ->
  #             if Enum.find_index(status_priority, &(&1 == status)) <
  #                  Enum.find_index(status_priority, &(&1 == acc)),
  #               do: status,
  #               else: acc
  #           end)

  #         # ✅ 3. Broadcast to sender’s personal channel (user:sender_id)
  #         WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
  #           "conversation_id" => conv_id,
  #           "message_id" => message_id,
  #           "updated_by" => user_id,
  #           "new_status" => combined_status
  #         })
  #       end

  #       json(conn, %{
  #         status: %{
  #           id: status_entry.id,
  #           message_id: status_entry.message_id,
  #           user_id: status_entry.user_id,
  #           status: status_entry.status,
  #           status_ts: status_entry.status_ts
  #         }
  #       })

  #     {:error, :unauthorized} ->
  #       conn
  #       |> put_status(:forbidden)
  #       |> json(%{error: "Not allowed to update this message status"})

  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> json(%{errors: render_changeset_errors(changeset)})
  #   end
  # end

  # def update(conn, %{"message_id" => message_id, "status_code" => new_status}) do
  #   user_id = conn.assigns[:user_id]

  #   case Messaging.update_message_status(message_id, user_id, new_status) do
  #     {:ok, status_entry} ->
  #       message = WhatsappClone.Repo.get!(WhatsappClone.Message, message_id)
  #       sender_id = message.sender_id
  #       conv_id = message.conversation_id

  #       if sender_id != user_id do
  #         # ✅ 1. Broadcast to chat channel for in-chat users
  #         WhatsappCloneWeb.Endpoint.broadcast("chat:#{conv_id}", "message_status_update", %{
  #           message_id: message_id,
  #           user_id: user_id,
  #           status: new_status
  #         })

  #         # ✅ 2. Compute combined status across all recipients (excluding sender)
  #         status_priority = ["pending", "sent", "delivered", "read"]

  #         other_statuses =
  #           from(ms in WhatsappClone.MessageStatus,
  #             where: ms.message_id == ^message_id and ms.user_id != ^sender_id,
  #             select: ms.status
  #           )
  #           |> WhatsappClone.Repo.all()

  #         combined_status =
  #           Enum.min_by(other_statuses, fn status ->
  #             Enum.find_index(status_priority, &(&1 == status)) || length(status_priority)
  #           end)

  #           Logger.debug("Other statuses for #{message_id}: #{inspect(other_statuses)}")

  #         # ✅ 3. Broadcast to sender’s personal channel
  #         WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
  #           "conversation_id" => conv_id,
  #           "message_id" => message_id,
  #           "updated_by" => user_id,
  #           "new_status" => combined_status
  #         })
  #       end

  #       json(conn, %{
  #         status: %{
  #           id: status_entry.id,
  #           message_id: status_entry.message_id,
  #           user_id: status_entry.user_id,
  #           status: status_entry.status,
  #           status_ts: status_entry.status_ts
  #         }
  #       })

  #     {:error, :unauthorized} ->
  #       conn
  #       |> put_status(:forbidden)
  #       |> json(%{error: "Not allowed to update this message status"})

  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> json(%{errors: render_changeset_errors(changeset)})
  #   end
  # end

  # working def update(conn, %{"message_id" => message_id, "status_code" => raw_status}) do
  #   user_id = conn.assigns[:user_id]
  #   new_status = String.downcase(raw_status)  # 👈 This is the key fix

  #   case Messaging.update_message_status(message_id, user_id, new_status) do
  #     {:ok, status_entry} ->
  #       message = WhatsappClone.Repo.get!(WhatsappClone.Message, message_id)
  #       sender_id = message.sender_id
  #       conv_id = message.conversation_id

  #       if sender_id != user_id do
  #         WhatsappCloneWeb.Endpoint.broadcast("chat:#{conv_id}", "message_status_update", %{
  #           message_id: message_id,
  #           user_id: user_id,
  #           status: new_status
  #         })

  #         fresh_statuses =
  #           WhatsappClone.Repo.all(
  #             from(ms in WhatsappClone.MessageStatus,
  #               where: ms.message_id == ^message_id and ms.user_id != ^sender_id
  #             )
  #           )

  #         combined_status =
  #           WhatsappCloneWeb.ConversationView.compute_status_summary(fresh_statuses, sender_id)

  #         WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
  #           "conversation_id" => conv_id,
  #           "message_id" => message_id,
  #           "updated_by" => user_id,
  #           "new_status" => combined_status || "sent"
  #         })
  #       end

  #       json(conn, %{
  #         status: %{
  #           id: status_entry.id,
  #           message_id: status_entry.message_id,
  #           user_id: status_entry.user_id,
  #           status: status_entry.status,
  #           status_ts: status_entry.status_ts
  #         }
  #       })

  #     {:error, :unauthorized} ->
  #       conn
  #       |> put_status(:forbidden)
  #       |> json(%{error: "Not allowed to update this message status"})

  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> json(%{errors: render_changeset_errors(changeset)})
  #   end
  # end


  def update(conn, %{"message_id" => message_id, "status_code" => raw_status}) do
    user_id = conn.assigns[:user_id]
    new_status = String.downcase(raw_status)

    if new_status != "read" do
      # Regular single update
      handle_single_status_update(conn, message_id, user_id, new_status)
    else
      # Bulk update all unread messages before this one
      message = WhatsappClone.Repo.get!(WhatsappClone.Message, message_id)
      conv_id = message.conversation_id

      earlier_unread_messages =
        from(m in WhatsappClone.Message,
          where:
            m.conversation_id == ^conv_id and
              m.inserted_at <= ^message.inserted_at and
              m.sender_id != ^user_id,
          left_join: ms in assoc(m, :status_entries),
          on: ms.user_id == ^user_id,
          where: is_nil(ms.status) or ms.status != "read",
          select: m
        )
        |> WhatsappClone.Repo.all()

      status_entries = Enum.map(earlier_unread_messages, fn msg ->
        {:ok, entry} = WhatsappClone.Messaging.update_message_status(msg.id, user_id, "read")

        # Broadcast to chat:channel
        WhatsappCloneWeb.Endpoint.broadcast("chat:#{conv_id}", "message_status_update", %{
          message_id: msg.id,
          user_id: user_id,
          status: "read"
        })

        # Compute fresh combined status and notify sender
        if msg.sender_id != user_id do
          fresh_statuses =
            WhatsappClone.Repo.all(
              from(ms in WhatsappClone.MessageStatus,
                where: ms.message_id == ^msg.id and ms.user_id != ^msg.sender_id
              )
            )

          combined =
            WhatsappCloneWeb.ConversationView.compute_status_summary(fresh_statuses, msg.sender_id)

          WhatsappCloneWeb.Endpoint.broadcast("user:#{msg.sender_id}", "message_status_updated", %{
            "conversation_id" => msg.conversation_id,
            "message_id" => msg.id,
            "updated_by" => user_id,
            "new_status" => combined || "sent"
          })
        end

        entry
      end)

      WhatsappCloneWeb.Endpoint.broadcast("user:#{user_id}", "unread_count_updated", %{
        "conversation_id" => conv_id,
        "unread_count" => 0
      })
      json(conn, %{read_messages: Enum.map(status_entries, & &1.message_id)})

      # ✅ Push unread_count_updated = 0 to the user's channel


    end
  end

  defp handle_single_status_update(conn, message_id, user_id, new_status) do
    case WhatsappClone.Messaging.update_message_status(message_id, user_id, new_status) do
      {:ok, status_entry} ->
        message = WhatsappClone.Repo.get!(WhatsappClone.Message, message_id)
        sender_id = message.sender_id
        conv_id = message.conversation_id

        # ✅ Push unread_count_updated = 0 to the user's channel
        # WhatsappCloneWeb.Endpoint.broadcast("user:#{user_id}", "unread_count_updated", %{
        #   "conversation_id" => conv_id,
        #   "unread_count" => 0
        # })

        if sender_id != user_id do
          # 🔹 Broadcast to chat channel
          WhatsappCloneWeb.Endpoint.broadcast("chat:#{conv_id}", "message_status_update", %{
            message_id: message_id,
            user_id: user_id,
            status: new_status
          })

          # 🔹 Compute combined status (excluding sender)
          fresh_statuses =
            WhatsappClone.Repo.all(
              from(ms in WhatsappClone.MessageStatus,
                where: ms.message_id == ^message_id and ms.user_id != ^sender_id
              )
            )

          combined_status =
            WhatsappCloneWeb.ConversationView.compute_status_summary(fresh_statuses, sender_id)

          # 🔹 Broadcast to sender’s personal channel
          WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
            "conversation_id" => conv_id,
            "message_id" => message_id,
            "updated_by" => user_id,
            "new_status" => combined_status || "sent"
          })
        end

        json(conn, %{
          status: %{
            id: status_entry.id,
            message_id: status_entry.message_id,
            user_id: status_entry.user_id,
            status: status_entry.status,
            status_ts: status_entry.status_ts
          }
        })

      {:error, :unauthorized} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Not allowed to update this message status"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: render_changeset_errors(changeset)})
    end
  end




  defp render_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
