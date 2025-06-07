defmodule WhatsappCloneWeb.FallbackController do
  use WhatsappCloneWeb, :controller

  @doc """
  Translates controller action results into valid `Plug.Conn` responses.
  """
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: errors})
  end

  def call(conn, {:error, :not_found}) do
    send_resp(conn, :not_found, "Not found")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Forbidden"})
  end
end
