defmodule WhatsappCloneWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "chat:*", WhatsappCloneWeb.ChatChannel


  channel "graph_updates:*", WhatsappCloneWeb.SocialGraphChannel


  # def connect(%{"token" => token}, socket, _connect_info) do
  #   case WhatsappClone.Auth.verify_token(token) do
  #     {:ok, user_id} ->
  #       {:ok, assign(socket, :user_id, user_id)}

  #     _error ->
  #       :error
  #   end
  # end
  def connect(%{"token" => token}, socket, _connect_info) do
    IO.puts("Socket connect received token: #{token}")

    case WhatsappClone.Auth.verify_token(token) do
      {:ok, user_id} ->
        IO.puts("Token verified for user_id: #{user_id}")
        {:ok, assign(socket, :user_id, user_id)}

      _error ->
        IO.puts("Token verification failed")
        :error
    end
  end

  def connect(_, _, _), do: :error

  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
