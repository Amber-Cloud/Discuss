defmodule DiscussWeb.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Discuss.Identicon


  schema "topics" do
    field :title, :string
    field :body, :string
    field :identicon, :string
    belongs_to :user, DiscussWeb.User
    has_many :comments, DiscussWeb.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:body, min: 5, max: 1000)
  end

  def identicon_changeset(changeset, %{"title" => title}) do
    identicon = Identicon.create_identicon(title)
    change(changeset, %{identicon: identicon})
  end
end