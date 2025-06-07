defmodule WhatsappCloneWeb.MessageStatusController do
  use WhatsappCloneWeb, :controller

  alias WhatsappClone.Messaging

  action_fallback WhatsappCloneWeb.FallbackController

  @doc """
  PATCH /api/messages/:message_id/status
  Body params: %{"status" => "delivered" | "read"}
  Requires `conn.assigns.user_id` to be the user updating their own status.
  """
  def update(conn, %{"message_id" => message_id, "status" => new_status}) do
    user_id = conn.assigns[:user_id]

    case Messaging.update_message_status(message_id, user_id, new_status) do
      {:ok, status_entry} ->
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
