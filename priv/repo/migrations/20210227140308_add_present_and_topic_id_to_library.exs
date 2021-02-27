defmodule Awatcher.Repo.Migrations.AddTopicIdToLibrary do
  use Ecto.Migration

  def change do
    alter table(:libraries) do
      add :present, :boolean, default: true
      add :topic_id, references(:topics)
    end
  end
end
