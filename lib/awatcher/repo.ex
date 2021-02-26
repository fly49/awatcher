defmodule Awatcher.Repo do
  use Ecto.Repo,
    otp_app: :awatcher,
    adapter: Ecto.Adapters.Postgres
end
