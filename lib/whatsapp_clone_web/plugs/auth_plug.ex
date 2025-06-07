# defmodule WhatsappCloneWeb.Plugs.AuthPlug do
#   import Plug.Conn
#   alias WhatsappCloneWeb.AuthToken

#   @behaviour Plug

#   def init(opts), do: opts

#   def call(conn, _opts) do
#     with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
#          {:ok, user_id} <- AuthToken.verify(token) do
#       assign(conn, :user_id, user_id)
#     else
#       _ ->
#         conn
#         |> Phoenix.Controller.json(%{error: "Unauthorized"})
#         |> halt()
#     end
#   end
# end

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

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- WhatsappClone.Auth.verify_token(token) do
      assign(conn, :user_id, user_id)
    else
      _ -> conn |> send_resp(401, "Unauthorized") |> halt()
    end
  end
end
