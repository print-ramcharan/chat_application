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

defmodule WhatsappClone.Auth do
  @moduledoc "JWT Auth helper"

  use Joken.Config

  @token_validity_days 7

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss, :jti])
  end

  def generate_token(user_id) do
    claims = %{
      "sub" => user_id,
      "exp" => DateTime.utc_now() |> DateTime.add(@token_validity_days * 86400, :second) |> DateTime.to_unix()
    }

    generate_and_sign(claims)
  end

  def verify_token(token) do
    case verify_and_validate(token) do
      {:ok, %{"sub" => user_id}} -> {:ok, user_id}
      _ -> {:error, :invalid_token}
    end
  end
end
