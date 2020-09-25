# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :myapp,
  ecto_repos: [MyApp.Repo]

# Configures the endpoint
config :myapp, MyAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cuZblQwYDyuNk5WD3wHCZeSXqy2n+zyxMlupKLDv6KSpwWlzPdnkCH5Az/3PqKAn",
  render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MyApp.PubSub,
  live_view: [signing_salt: "ao2GbWRx"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
