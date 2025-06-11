defmodule WhatsappCloneWeb.UserController do
  use WhatsappCloneWeb, :controller
  import WhatsappCloneWeb.ErrorHelpers

  alias WhatsappClone.Accounts

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        send_resp(conn, 404, "User not found")

      user ->
        json(conn, %{id: user.id, username: user.username, phone_number: user.phone_number})
    end
  end

  # def avatar(conn, %{"avatar_url" => avatar_url}) do
  #   user_id = conn.assigns[:user_id]

  #   # case Accounts.update_avatar(user_id, avatar_url) do
  #   #   {:ok, %WhatsappClone.User{} = user} ->
  #   #     json(conn, %{message: "Avatar updated", avatar_url: user.avatar_data})

  #   #   {:error, changeset} ->
  #   #     conn
  #   #     |> put_status(:unprocessable_entity)
  #   #     |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)})
  #   # end
  #   case Accounts.update_avatar(user_id, avatar_url) do
  #     {:ok, user} ->
  #       render(conn, "show.json", user: user)

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render("error.json", %{errors: translate_errors(changeset)})

  #     {:error, :invalid_avatar_data} ->
  #       conn
  #       |> put_status(:bad_request)
  #       |> json(%{error: "Invalid image data"})
  #   end

  # end

  # def avatar(conn, %{"avatar_url" => base64}) do
  #   IO.inspect(base64, label: ">>> Received base64 in controller")
  #    user = conn.assigns[:user_id]

  #   case Accounts.update_avatar(user, %{"avatar_url" => base64}) do
  #     {:ok, updated_user} ->
  #       render(conn, "user.json", user: updated_user)

  #     {:error, changeset} ->
  #       IO.inspect(changeset.errors, label: ">>> Avatar update errors")
  #       conn
  #       |> put_status(:bad_request)
  #       |> json(%{error: "Invalid avatar"})
  #   end
  # end
  def avatar(conn, %{"avatar_url" => base64}) do
    IO.inspect(base64, label: ">>> Received base64 in controller")
    user_id = conn.assigns[:user_id]

    case Accounts.update_avatar(user_id, base64) do
      {:ok, updated_user} ->
        render(conn, WhatsappCloneWeb.UserView, "user.json", user: updated_user)

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors, label: ">>> Avatar update errors")
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: translate_errors(changeset)})

      {:error, :invalid_avatar_data} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid avatar data"})
    end
  end



  def search(conn, %{"query" => query}) do
    users = Accounts.search_users(%{"query" => query})
    json(conn, users)
  end

end
