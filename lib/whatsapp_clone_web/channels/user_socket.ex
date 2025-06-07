# defmodule WhatsappCloneWeb.UserSocket do
#   use Phoenix.Socket

#   ## Channels
#   channel "chat:*", WhatsappCloneWeb.ChatChannel

#   # Connect with params including user_id to assign the user to the socket
#   def connect(%{"user_id" => user_id}, socket, _connect_info) do
#     {:ok, assign(socket, :user_id, user_id)}
#   end

#   def id(_socket), do: nil
# end
# defmodule WhatsappCloneWeb.UserSocket do
#   use Phoenix.Socket

#   ## Channels
#   channel "chat:*", WhatsappCloneWeb.ChatChannel

#   # Connect function stays the same
#   def connect(%{"token" => token}, socket, _connect_info) do
#     case WhatsappCloneWeb.AuthToken.verify(token) do
#       {:ok, user_id} ->
#         {:ok, assign(socket, :user_id, user_id)}
#       _ ->
#         :error
#     end
#   end

#   def connect(_params, _socket, _connect_info), do: :error

#   def id(socket), do: "users_socket:#{socket.assigns.user_id}"
# end

defmodule WhatsappCloneWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "chat:*", WhatsappCloneWeb.ChatChannel

  # Clients connect with a token param: %{ "token" => JWT or Phoenix.Token }
  def connect(%{"token" => token}, socket, _connect_info) do
    case WhatsappCloneWeb.AuthToken.verify(token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      _error ->
        :error
    end
  end

  def connect(_, _, _), do: :error

  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
