# defmodule WhatsappClone.Auth do
#   @moduledoc false
#   @salt "user auth"  # Must match the salt used in `sign`

#   def verify_token(token) do
#     max_age = 7 * 24 * 60 * 60  # 7 days in seconds

#     Phoenix.Token.verify(WhatsappCloneWeb.Endpoint, @salt, token, max_age: max_age)
#   end
# end

# defmodule WhatsappClone.Auth do
#   @moduledoc "JWT Auth helper"

#   use Joken.Config

#   @secret_key "" # Replace with System.get_env or Application config in prod
#   @token_validity_days 7

#   def generate_token(user_id) do
#     claims = %{
#       "sub" => user_id,
#       "exp" => DateTime.utc_now() |> DateTime.add(@token_validity_days * 86400, :second) |> DateTime.to_unix()
#     }

#     token_config = default_claims(skip: [:aud, :iss, :jti])
#     signer = Joken.Signer.create("HS256", @secret_key)
#     Joken.generate_and_sign(claims, signer)
#   end

#   def verify_token(token) do
#     signer = Joken.Signer.create("HS256", @secret_key)

#     case Joken.verify_and_validate(token, signer) do
#       {:ok, %{"sub" => user_id}} -> {:ok, user_id}
#       _ -> {:error, :invalid_token}
#     end
#   end
# end

# defmodule WhatsappClone.Auth do
#   @moduledoc "JWT Auth helper"

#   use Joken.Config

#   @token_validity_days 7

#   @impl true
#   def token_config do
#     default_claims(skip: [:aud, :iss, :jti])
#   end

#   def generate_token(user_id) do
#     claims = %{
#       "sub" => user_id,
#       "exp" => DateTime.utc_now() |> DateTime.add(@token_validity_days * 86400, :second) |> DateTime.to_unix()
#     }

#     generate_and_sign(claims)
#   end

#   def verify_token(token) do
#     case verify_and_validate(token) do
#       {:ok, %{"sub" => user_id}} -> {:ok, user_id}
#       _ -> {:error, :invalid_token}
#     end
#   end
# end

# defmodule WhatsappClone.Auth do
#   @moduledoc "JWT Auth helper"

#   use Joken.Config

#   @token_validity_days 7

#   @impl true
#   def token_config do
#     default_claims(skip: [:aud, :iss, :jti])
#   end

#   def generate_token(user_id) do
#     claims = %{
#       "sub" => user_id,
#       "exp" => DateTime.utc_now() |> DateTime.add(@token_validity_days * 86400, :second) |> DateTime.to_unix()
#     }

#     generate_and_sign(claims)
#   end

#   def verify_token(token) do
#     case verify_and_validate(token) do
#       {:ok, %{"sub" => user_id}} -> {:ok, user_id}
#       _ -> {:error, :invalid_token}
#     end
#   end
# end

# defmodule WhatsappClone.Auth do
#   @moduledoc "JWT Auth helper"

#   use Joken.Config

#   @access_token_minutes 15
#   @refresh_token_days 30

#   @impl true
#   def token_config do
#     default_claims(skip: [:aud, :iss, :jti])
#   end

#   # Generate an access token (15 min)
#   def generate_access_token(user_id) do
#     generate_token(user_id, %{"type" => "access"}, [ttl: {@access_token_minutes, :minute}])
#   end

#   # Generate a refresh token (30 days)
#   def generate_refresh_token(user_id) do
#     generate_token(user_id, %{"type" => "refresh"}, [ttl: {@refresh_token_days, :day}])
#   end

#   # General helper if you want to customize further
#   def generate_token(user_id, extra_claims, opts \\ []) do
#     ttl_seconds =
#       case opts do
#         [ttl: {value, unit}] ->
#           case unit do
#             :second -> value
#             :minute -> value * 60
#             :hour -> value * 3600
#             :day -> value * 86_400
#             _ -> @refresh_token_days * 86_400
#           end

#         _ ->
#           @refresh_token_days * 86_400
#       end

#     claims =
#       %{
#         "sub" => user_id,
#         "exp" =>
#           DateTime.utc_now()
#           |> DateTime.add(ttl_seconds, :second)
#           |> DateTime.to_unix()
#       }
#       |> Map.merge(extra_claims)

#     generate_and_sign(claims)
#   end

#   # Verifies a token without checking its type
#   def verify_token(token) do
#     case verify_and_validate(token) do
#       {:ok, claims = %{"sub" => user_id}} -> {:ok, user_id, claims}
#       _ -> {:error, :invalid_token}
#     end
#   end

#   # Verifies a token and ensures it has the expected "type"
#   def verify_token(token, expected_type) do
#     case verify_and_validate(token) do
#       {:ok, %{"sub" => user_id, "type" => ^expected_type} = claims} ->
#         {:ok, user_id, claims}

#       _ ->
#         {:error, :invalid_token}
#     end
#   end
# end

defmodule WhatsappClone.Auth do
  @moduledoc "JWT Auth helper"
  use Joken.Config

  @access_token_minutes 2
  @refresh_token_days 30

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss, :jti, :nbf, :iat])
  end


  def generate_access_token(user_id) do
    generate_token(user_id, %{"type" => "access"}, [ttl: {@access_token_minutes, :hours}])
  end

  def generate_refresh_token(user_id) do
    generate_token(user_id, %{"type" => "refresh"}, [ttl: {@refresh_token_days, :day}])
  end

  def generate_token(user_id, extra_claims, opts \\ []) do
    ttl_seconds =
      case opts do
        [ttl: {value, unit}] ->
          case unit do
            :second -> value
            :minute -> value * 60
            :hour -> value * 3600
            :day -> value * 86_400
            _ -> @refresh_token_days * 86_400
          end

        _ ->
          @refresh_token_days * 86_400
      end

    claims =
      %{
        "sub" => user_id,
        "exp" =>
          DateTime.utc_now()
          |> DateTime.add(ttl_seconds, :second)
          |> DateTime.to_unix()
      }
      |> Map.merge(extra_claims)

    generate_and_sign(claims)
  end

  # Corrected verify_token returning {:ok, user_id}
  def verify_token(token) do
    case verify_and_validate(token) do
      {:ok, %{"sub" => user_id}} -> {:ok, user_id}
      _ -> {:error, :invalid_token}
    end
  end

  # Corrected verify_token with expected type
  # def verify_token(token, expected_type) do
  #   case verify_and_validate(token) do
  #     {:ok, %{"sub" => user_id, "type" => ^expected_type}} -> {:ok, user_id}
  #     _ -> {:error, :invalid_token}
  #   end
  # end
  # def verify_token(token, expected_type) do
  #   case verify_and_validate(token) do
  #     {:ok, %{"sub" => user_id, "type" => ^expected_type}} -> {:ok, user_id}
  #     _ -> {:error, :invalid_token}
  #   end
  # end
  def verify_token(token, expected_type) do
    result = verify_and_validate(token)
    IO.inspect(result, label: "verify_and_validate result")

    case result do
      {:ok, %{"sub" => user_id, "type" => ^expected_type}} -> {:ok, user_id}
      {:ok, claims} ->
        IO.inspect(claims, label: "Claims found, but type mismatch")
        {:error, :invalid_token}
      {:error, reason} ->
        IO.inspect(reason, label: "Validation error")
        {:error, :invalid_token}
      other ->
        IO.inspect(other, label: "Unexpected result")
        {:error, :invalid_token}
    end
  end


end
