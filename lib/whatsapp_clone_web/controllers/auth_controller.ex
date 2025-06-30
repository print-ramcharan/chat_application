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
        {:ok, access_token, _claims} =
          Auth.generate_token(user.id, %{"type" => "access"}, ttl: {15, :minute})

        {:ok, refresh_token, _refresh_claims} =
          Auth.generate_token(user.id, %{"type" => "refresh"}, ttl: {30, :day})

        json(conn, %{
          user: %{
            id: user.id,
            username: user.username,
            phone_number: user.phone_number,
            display_name: user.display_name,
            avatar_url: encode_avatar(user.avatar_data)
          },
          access_token: access_token,
          refresh_token: refresh_token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  @doc """
  POST /api/refresh_token
  """
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Auth.verify_token(refresh_token, "refresh") do
      {:ok, user_id} ->
        {:ok, new_access_token, _} =
          Auth.generate_token(user_id, %{"type" => "access"}, [ttl: {15, :minute}])

        json(conn, %{access_token: new_access_token})

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired token"})
    end
  end

  @doc """
  POST /api/verify_token
  """
  def verify(conn, _params) do
    IO.inspect(get_req_header(conn, "authorization"), label: "Authorization header")

    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        IO.inspect(token, label: "Token to verify")
        case WhatsappClone.Auth.verify_token(token, "access") do
          {:ok, _user_id} ->
            json(conn, %{valid: true})

          _ ->
            conn
            |> put_status(:unauthorized)
            |> json(%{valid: false})
        end


      other ->
        IO.inspect(other, label: "No Authorization header")
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Missing Authorization header"})
    end
  end



  # Helpers
  defp encode_avatar(nil), do: nil
  defp encode_avatar(data), do: "data:image/png;base64," <> Base.encode64(data)

  defp render_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.flat_map(fn {field, messages} ->
      Enum.map(messages, fn msg -> "#{field}: #{msg}" end)
    end)
  end
end
