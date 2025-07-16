defmodule WhatsappClone.Auth do
  @moduledoc "JWT Auth helper"
  use Joken.Config

  @access_token_minutes 29
  @refresh_token_days 30

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss, :jti, :nbf, :iat])
  end


  def generate_access_token(user_id) do
    generate_token(user_id, %{"type" => "access"}, [ttl: {@access_token_minutes, :days}])
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
