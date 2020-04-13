defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  #using alias allows us to use DiscussWeb's fun-s
  alias DiscussWeb.Topic
  alias Discuss.Repo
  import Ecto.Query, only: [from: 2]

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    #conn = put_in(conn.assigns.user, %{})
    query = from(topic in Topic, order_by: [desc: topic.inserted_at])
    topics = Repo.all(query)
    render(conn, "index.html", topics: topics)
  end

  def show(conn, %{"id" => topic_id}) do

    case Repo.get(Topic, topic_id) do
      topic = %Topic{} ->
        topic =
          topic
          |> Repo.preload(comments: [:user])
          |> Repo.preload([:user])
          render(conn, "show.html", topic: topic)
      nil ->
        conn
        |> put_flash(:error, "This topic doesn't exist")
        |> redirect(to: Routes.topic_path(conn, :index))
        |> halt()
    end
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{}) #1st arg = struct, 2nd = params
    render(conn,  "new.html", changeset: changeset) #add changeset kw so that new.html gets @changeset from here
  end

  def create(conn, %{"topic" => topic}) do
    changeset = conn.assigns.user
      |> Ecto.build_assoc(:topics)
      |> Topic.changeset(topic)
      |> Topic.identicon_changeset(topic)
    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created") #to show messages to a user once
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Oops! Please submit a valid topic name")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)

    render(conn, "edit.html", changeset: changeset, topic: topic)
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Oops! Please submit a valid topic")
        |> render("edit.html", changeset: changeset, topic: old_topic)
    end
  end

  def delete(conn, %{"id" => topic_id}) do #id needs to be id due to conventions
    topic = Repo.get!(Topic, topic_id) |> Repo.preload([:comments])
    topic.comments |> Enum.each(&Repo.delete!/1)
    topic |> Repo.delete!()

    #no case here! if a user can't delete the topic, we don't want them to
    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  defp check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot edit or delete this topic")
      |> redirect(to: Routes.topic_path(conn, :index))
      |> halt()
    end
  end
end