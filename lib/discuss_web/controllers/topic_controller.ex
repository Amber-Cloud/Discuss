defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  #using alias allows us to use DiscussWeb's fun-s
  alias DiscussWeb.Topic
  alias Discuss.Repo

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]

  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    IO.inspect(conn.assigns)
    #conn = put_in(conn.assigns.user, %{})
    topics = Repo.all(Topic)
    render(conn, "index.html", topics: topics)
  end

  def show(conn, %{"id" => topic_id}) do
    topic =
      Topic
      |> Repo.get!(topic_id) # ! -> if no record -> error 404
      |> Repo.preload(comments: [:user])
      |> Repo.preload([:user])
    render(conn, "show.html", topic: topic)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{}) #1st arg = struct, 2nd = params

    render(conn,  "new.html", changeset: changeset) #add changeset kw so that new.html gets @changeset from here
  end

  def create(conn, params = %{"topic" => topic}) do
    changeset = conn.assigns.user
      |> Ecto.build_assoc(:topics)
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created") #to show messages to a user once
        |> redirect(to: Routes.topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Oops! Please submit a valid topic name.")
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
    Repo.get!(Topic, topic_id) |> Repo.delete!()

    #no case here! if a user can't delete the topic, we don't want them to
    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: Routes.topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot edit or delete this topic.")
      |> redirect(to: Routes.topic_path(conn, :index))
      |> halt()
    end
  end
end