defmodule WhatsappCloneWeb.MessageStatusController do
  use WhatsappCloneWeb, :controller

  alias WhatsappClone.Messaging

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

  def update(conn, %{"message_id" => message_id, "status_code" => new_status}) do
    user_id = conn.assigns[:user_id]

    case Messaging.update_message_status(message_id, user_id, new_status) do
      {:ok, status_entry} ->
        message = WhatsappClone.Repo.get!(WhatsappClone.Message, message_id)
        sender_id = message.sender_id
        conv_id = message.conversation_id

        if sender_id != user_id do
          # ✅ 1. Broadcast to chat channel for in-chat users
          WhatsappCloneWeb.Endpoint.broadcast("chat:#{conv_id}", "message_status_update", %{
            message_id: message_id,
            user_id: user_id,
            status: new_status
          })

          # ✅ 2. Compute combined status across all recipients (except sender)
          status_priority = ["pending", "sent", "delivered", "read"]

          other_statuses =
            from(ms in WhatsappClone.MessageStatus,
              where: ms.message_id == ^message_id and ms.user_id != ^sender_id,
              select: ms.status
            )
            |> WhatsappClone.Repo.all()

          combined_status =
            Enum.reduce(other_statuses, "read", fn status, acc ->
              if Enum.find_index(status_priority, &(&1 == status)) <
                   Enum.find_index(status_priority, &(&1 == acc)),
                do: status,
                else: acc
            end)

          # ✅ 3. Broadcast to sender’s personal channel (user:sender_id)
          WhatsappCloneWeb.Endpoint.broadcast("user:#{sender_id}", "message_status_updated", %{
            "conversation_id" => conv_id,
            "message_id" => message_id,
            "updated_by" => user_id,
            "new_status" => combined_status
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
