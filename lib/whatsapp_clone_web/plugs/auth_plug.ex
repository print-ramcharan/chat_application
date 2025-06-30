# defmodule WhatsappCloneWeb.Plugs.AuthPlug do
#   import Plug.Conn

#   def init(opts), do: opts

#   def call(conn, _opts) do
#     with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
#          {:ok, user_id} <- WhatsappClone.Auth.verify_token(token) do
#       assign(conn, :user_id, user_id)
#     else
#       _ -> conn |> send_resp(401, "Unauthorized") |> halt()
#     end
#   end
# end

defmodule WhatsappCloneWeb.Plugs.AuthPlug do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case WhatsappClone.Auth.verify_token(token) do
          {:ok, user_id} ->
            assign(conn, :user_id, user_id)

          {:error, reason} ->
            Logger.debug("Token verification failed: #{inspect(reason)}")
            conn
            |> send_resp(401, "Unauthorized")
            |> halt()
        end

      _ ->
        Logger.debug("Authorization header missing or malformed")
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end
end
