defmodule Awatcher.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :name, :string
      add :url, :string
      add :description, :text
      add :stars, :integer
      add :last_commit, :utc_datetime

      timestamps()
    end

    create unique_index(:libraries, [:name])
  end
end
