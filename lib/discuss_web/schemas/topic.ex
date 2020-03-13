defmodule DiscussWeb.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    field :body, :string
    belongs_to :user, DiscussWeb.User
    has_many :comments, DiscussWeb.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:body, min: 5, max: 10000)
  end
end