# defmodule WhatsappCloneWeb.DeviceController do
#   use WhatsappCloneWeb, :controller
#   alias WhatsappClone.Accounts

#   action_fallback WhatsappCloneWeb.FallbackController

#   @doc """
#   POST /api/devices
#   Headers must include a valid auth token that sets `conn.assigns.user_id`.
#   Body params: %{"device_token" => "...", "platform" => "..."}
#   """
#   def create(conn, %{"device_token" => _} = device_params) do
#     user_id = conn.assigns[:user_id]

#     case Accounts.create_device(user_id, device_params) do
#       {:ok, device} ->
#         conn
#         |> put_status(:created)
#         |> json(%{device: %{id: device.id, device_token: device.device_token}})

#       {:error, changeset} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: render_changeset_errors(changeset)})
#     end
#   end

#   @doc """
#   DELETE /api/devices/:id
#   """
#   def delete(conn, %{"id" => id}) do
#     user_id = conn.assigns[:user_id]

#     case Accounts.delete_device(user_id, id) do
#       :ok -> send_resp(conn, 204, "")
#       {:error, :not_found} -> send_resp(conn, 404, "Device not found")
#     end
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end

defmodule WhatsappCloneWeb.DeviceController do
  use WhatsappCloneWeb, :controller
  alias WhatsappClone.Accounts

  action_fallback WhatsappCloneWeb.FallbackController

  @doc """
  POST /api/devices
  Headers must include a valid auth token that sets `conn.assigns.user_id`.
  Body params must include:
    %{
      "device_token" => "...",
      "platform" => "...",
      "device_name" => "...",
      "public_key" => "..."
    }
  """
  def create(conn, device_params) do
    user_id = conn.assigns[:user_id]
    # Merge user_id into params before sending to Accounts
    params = Map.put(device_params, "user_id", user_id)

    case Accounts.create_device(params) do
      {:ok, device} ->
        conn
        |> put_status(:created)
        |> json(%{device: %{id: device.id, device_token: device.device_token}})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: render_changeset_errors(changeset)})
    end
  end

  @doc """
  DELETE /api/devices/:id
  """
  def delete(conn, %{"id" => id}) do
    user_id = conn.assigns[:user_id]

    case Accounts.delete_device(user_id, id) do
      :ok -> send_resp(conn, 204, "")
      {:error, :not_found} -> send_resp(conn, 404, "Device not found")
    end
  end

  defp render_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
