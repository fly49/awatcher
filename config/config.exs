# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :awatcher,
  ecto_repos: [Awatcher.Repo]

# Configures the endpoint
config :awatcher, AwatcherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pcfM38BXhKdVaLV/soN8+Xryi+6THBQvO8zfn23ctRd2omFi+V+IoZR9H2ffZbtO",
  render_errors: [view: AwatcherWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Awatcher.PubSub,
  live_view: [signing_salt: "JAl20NFb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
