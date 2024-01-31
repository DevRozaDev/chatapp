# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chat_app,
  ecto_repos: [ChatApp.Repo],
  generators: [binary_id: false]

# Configures the endpoint
config :chat_app, ChatAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4ICr7DxoLHlFN7kouxdCLE0xg1B/yi6xOHdqQxNGlGyqnrTvw0q2Jy6K0017129t",
  render_errors: [view: ChatAppWeb.ErrorView, accepts: ~w(json), default_format: "json"],
  pubsub: [name: ChatApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
