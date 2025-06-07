defmodule WhatsappCloneWeb.UserController do
  use WhatsappCloneWeb, :controller
  alias WhatsappClone.Accounts

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        send_resp(conn, 404, "User not found")

      user ->
        json(conn, %{id: user.id, username: user.username, phone_number: user.phone_number})
    end
  end

  def search(conn, %{"query" => query}) do
    users = Accounts.search_users(%{"query" => query})
    json(conn, users)
  end

end
