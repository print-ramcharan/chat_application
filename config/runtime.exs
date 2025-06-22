import Config

if System.get_env("PHX_SERVER") do
  config :whatsapp_clone, WhatsappCloneWeb.Endpoint, server: true
end

if config_env() == :prod do

  config :logger, :console,
    format: "[$level] $message\n",
    level: :debug

  config :logger, level: :debug

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :whatsapp_clone, WhatsappClone.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # Firebase server key (if you're sending push via FCM)
  config :whatsapp_clone,
    fcm_server_key: System.get_env("FCM_SERVER_KEY")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :whatsapp_clone, WhatsappCloneWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base,
    live_view: [
      signing_salt: System.fetch_env!("LIVE_VIEW_SIGNING_SALT")
    ]


  # ✅ Joken secret via env
  config :joken,
    default_signer: System.fetch_env!("JWT_SECRET")


  # ✅ Goth config from Firebase JSON in env
  config :goth, WhatsappClone.Goth,
    json: System.fetch_env!("FIREBASE_CREDENTIALS_JSON")
end
