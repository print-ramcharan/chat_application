defmodule WhatsappCloneWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :whatsapp_clone

  @session_options [
    store: :cookie,
    key: "_whatsapp_clone_key",
    signing_salt: "AjDxAtOt",
    same_site: "Lax"
  ]

  # LiveView socket
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # User socket for real-time chat channels
  socket "/socket", WhatsappCloneWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve static files from "priv/static"
  plug Plug.Static,
    at: "/",
    from: :whatsapp_clone,
    gzip: false,
    only: WhatsappCloneWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :whatsapp_clone
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug WhatsappCloneWeb.Router
end
