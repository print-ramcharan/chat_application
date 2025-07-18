defmodule WhatsappClone.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WhatsappCloneWeb.Telemetry,
      WhatsappClone.Repo,
      {DNSCluster, query: Application.get_env(:whatsapp_clone, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WhatsappClone.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WhatsappClone.Finch},
      # Start a worker by calling: WhatsappClone.Worker.start_link(arg)
      # {WhatsappClone.Worker, arg},
      # Start to serve requests, typically the last entry
      WhatsappCloneWeb.Endpoint,
      WhatsappCloneWeb.Presence,
      WhatsappClone.SocialGraph,
      {Goth, name: WhatsappClone.Goth}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WhatsappClone.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhatsappCloneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
