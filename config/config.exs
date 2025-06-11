# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :whatsapp_clone,
  ecto_repos: [WhatsappClone.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :whatsapp_clone, WhatsappCloneWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: WhatsappCloneWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WhatsappClone.PubSub,
  live_view: [signing_salt: "8kg3VF+k"]


  config :joken,
  default_signer: "KnnD7jyxnhg0En/Zs4+XMXUFAVacWMV1uI+8b3EjEZNyBpdbfz9te6Z9ymLlOYz"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :whatsapp_clone, WhatsappClone.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Esbuild version config
config :esbuild,
  version: "0.25.0",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]



# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
