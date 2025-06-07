# defmodule WhatsappCloneWeb.AuthController do
#   use WhatsappCloneWeb, :controller

#   alias WhatsappClone.Accounts
#   alias WhatsappClone.User

#   # Register endpoint: POST /api/register
#   def register(conn, params) do
#     # Directly pass all params for user creation
#     case Accounts.create_user(params) do
#       {:ok, %User{} = user} ->
#         conn
#         |> put_status(:created)
#         |> json(%{
#           id: user.id,
#           username: user.username,
#           phone_number: user.phone_number,
#           display_name: user.display_name,
#           avatar_url: user.avatar_url
#         })

#       {:error, changeset} ->
#         conn
#         |> put_status(:bad_request)
#         |> json(%{errors: changeset_errors(changeset)})
#     end
#   end

#   # Login endpoint: POST /api/login
#   def login(conn, %{"username" => username}) do
#     case Accounts.get_user_by_username(username) do
#       nil ->
#         conn
#         |> put_status(:unauthorized)
#         |> json(%{error: "Invalid username"})

#       user ->
#         # No password for now, just return user info
#         conn
#         |> put_status(:ok)
#         |> json(%{
#           id: user.id,
#           username: user.username,
#           phone_number: user.phone_number,
#           display_name: user.display_name,
#           avatar_url: user.avatar_url,
#           public_key: user.public_key
#         })
#     end
#   end

#   # Helper to format changeset errors nicely
#   defp changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
#       Enum.reduce(opts, msg, fn {key, val}, acc ->
#         String.replace(acc, "%{#{key}}", to_string(val))
#       end)
#     end)
#   end
# end

# defmodule WhatsappCloneWeb.AuthController do
#   use WhatsappCloneWeb, :controller
#   alias WhatsappClone.Accounts

#   action_fallback WhatsappCloneWeb.FallbackController

#   @doc """
#   POST /api/register
#   Params: %{"username" => "...", "phone_number" => "...", "display_name" => "...",
#            "avatar_url" => "...", "public_key" => "...", "password" => "..."}
#   """
#   def register(conn, %{
#         "username" => _,
#         "phone_number" => _,
#         "display_name" => _,
#         "password" => _
#       } = params) do
#     case Accounts.register_user(params) do
#       {:ok, user} ->
#         conn
#         |> put_status(:created)
#         |> json(%{user: %{id: user.id, username: user.username, phone_number: user.phone_number}})

#       {:error, changeset} ->
#         conn
#         |> put_status(:unprocessable_entity)
#         |> json(%{errors: render_changeset_errors(changeset)})
#     end
#   end

#   @doc """
#   POST /api/login
#   Params: %{"phone_number" => "...", "password" => "..."}
#   """
#   def login(conn, %{"phone_number" => phone_number, "password" => password}) do
#     case Accounts.authenticate_user(phone_number, password) do
#       {:ok, user, token} ->
#         json(conn, %{user: %{id: user.id, username: user.username}, token: token})

#       {:error, :invalid_credentials} ->
#         conn
#         |> put_status(:unauthorized)
#         |> json(%{error: "Invalid credentials"})
#     end
#   end

#   defp render_changeset_errors(changeset) do
#     Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
#   end
# end


defmodule WhatsappCloneWeb.AuthController do
  use WhatsappCloneWeb, :controller
  alias WhatsappClone.Accounts
  alias WhatsappClone.Auth

  action_fallback WhatsappCloneWeb.FallbackController

  @doc """
  POST /api/register
  """
  def register(conn, %{
        "username" => _,
        "phone_number" => _,
        "display_name" => _,
        "password" => _
      } = params) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{
          user: %{
            id: user.id,
            username: user.username,
            phone_number: user.phone_number
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: render_changeset_errors(changeset)})
    end
  end

  @doc """
  POST /api/login
  """
  def login(conn, %{"phone_number" => phone_number, "password" => password}) do
    case Accounts.authenticate_user(phone_number, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Auth.generate_token(user.id)

        json(conn, %{
          user: %{
            id: user.id,
            username: user.username,
            phone_number: user.phone_number,
            display_name: user.display_name
          },
          token: token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  defp render_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
