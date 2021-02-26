defmodule Awatcher.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Awatcher.Repo,
      # Start the Telemetry supervisor
      AwatcherWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Awatcher.PubSub},
      # Start the Endpoint (http/https)
      AwatcherWeb.Endpoint
      # Start a worker by calling: Awatcher.Worker.start_link(arg)
      # {Awatcher.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Awatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwatcherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
