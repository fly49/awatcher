defmodule Awatcher.Records.Library do
  use Ecto.Schema
  import Ecto.Changeset

  schema "libraries" do
    field :description, :string
    field :name, :string
    field :url, :string
    field :stars, :integer
    field :last_commit, :utc_datetime
    belongs_to :topic, Awatcher.Records.Topic

    timestamps()
  end

  @doc false
  def changeset(library, attrs) do
    library
    |> cast(attrs, [:name, :url, :description, :stars, :last_commit, :topic_id])
    |> validate_required([:name, :url, :description, :topic_id])
    |> unique_constraint(:name)
    |> assoc_constraint(:topic)
  end
end
