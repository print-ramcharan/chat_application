import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: WhatsappClone.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

config :logger, level: :debug

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
