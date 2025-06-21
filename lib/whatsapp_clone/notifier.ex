defmodule WhatsappClone.Notifier do
  require Logger
  alias Tesla.Env

  @fcm_url "https://fcm.googleapis.com/v1/projects/chat-application-0001/messages:send"

  # def send_fcm_message(token, %{title: title, body: body, data: data}) when is_binary(token) do
  #   with {:ok, %{token: access_token}} <- Goth.fetch(WhatsappClone.Goth, "https://www.googleapis.com/auth/firebase.messaging")    do
  #     headers = [
  #       {"Authorization", "Bearer #{access_token}"},
  #       {"Content-Type", "application/json"}
  #     ]

  #     body = %{
  #       message: %{
  #         token: token,
  #         notification: %{
  #           title: title,
  #           body: body
  #         }
  #       }
  #     }

  #     Logger.debug("📤 Sending FCM notification via v1 API to #{token}")

  #     case Tesla.post(@fcm_url, Jason.encode!(body), headers: headers) do
  #       {:ok, %Env{status: 200}} ->
  #         Logger.debug("✅ FCM sent successfully")

  #       {:ok, %Env{status: code, body: resp}} ->
  #         Logger.error("⚠️ FCM failed with status #{code}: #{inspect(resp)}")

  #       {:error, err} ->
  #         Logger.error("❌ Error sending FCM: #{inspect(err)}")
  #     end
  #   else
  #     {:error, reason} ->
  #       Logger.error("❌ Failed to fetch access token for FCM: #{inspect(reason)}")
  #   end
  # end
  # def send_fcm_message(token, %{title: title, body: body, data: data}) when is_binary(token) do
  #   with {:ok, %{token: access_token}} <- Goth.fetch(WhatsappClone.Goth, "https://www.googleapis.com/auth/firebase.messaging") do
  #     headers = [
  #       {"Authorization", "Bearer #{access_token}"},
  #       {"Content-Type", "application/json"}
  #     ]

  #     # Sanitize reserved keys (like message_type → msg_type)
  #     sanitized_data =
  #       data
  #       |> Enum.map(fn
  #         {"message_type", val} -> {"msg_type", val}
  #         {k, v} -> {to_string(k), v}
  #       end)
  #       |> Enum.into(%{})

  #     body = %{
  #       message: %{
  #         token: token,
  #         notification: %{
  #           title: title,
  #           body: body
  #         },
  #         data: sanitized_data
  #       }
  #     }

  #     Logger.debug("📤 Sending FCM notification via v1 API to #{token}")

  #     case Tesla.post(@fcm_url, Jason.encode!(body), headers: headers) do
  #       {:ok, %Tesla.Env{status: 200}} ->
  #         Logger.debug("✅ FCM sent successfully")

  #       {:ok, %Tesla.Env{status: code, body: resp}} ->
  #         Logger.error("⚠️ FCM failed with status #{code}: #{inspect(resp)}")

  #       {:error, err} ->
  #         Logger.error("❌ Error sending FCM: #{inspect(err)}")
  #     end
  #   else
  #     {:error, reason} ->
  #       Logger.error("❌ Failed to fetch access token for FCM: #{inspect(reason)}")
  #   end
  # end

  def send_fcm_message(token, %{title: title, body: body, data: data}) when is_binary(token) do
    with {:ok, %{token: access_token}} <- Goth.fetch(WhatsappClone.Goth, "https://www.googleapis.com/auth/firebase.messaging") do
      headers = [
        {"Authorization", "Bearer #{access_token}"},
        {"Content-Type", "application/json"}
      ]

      sanitized_data =
        data
        |> Enum.map(fn
          {"message_type", val} -> {"msg_type", val}
          {k, v} -> {to_string(k), v}
        end)
        |> Enum.into(%{})

      body = %{
        message: %{
          token: token,
          notification: %{
            title: title,
            body: body
          },
          android: %{
            priority: "high"
          },
          data: sanitized_data
        }
      }

      Logger.debug("📤 Sending FCM notification via v1 API to #{token}")

      case Tesla.post(@fcm_url, Jason.encode!(body), headers: headers) do
        {:ok, %Tesla.Env{status: 200}} ->
          Logger.debug("✅ FCM sent successfully")

        {:ok, %Tesla.Env{status: code, body: resp}} ->
          Logger.error("⚠️ FCM failed with status #{code}: #{inspect(resp)}")

        {:error, err} ->
          Logger.error("❌ Error sending FCM: #{inspect(err)}")
      end
    else
      {:error, reason} ->
        Logger.error("❌ Failed to fetch access token for FCM: #{inspect(reason)}")
    end
  end



end
