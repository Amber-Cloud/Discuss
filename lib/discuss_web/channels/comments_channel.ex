defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel
  alias DiscussWeb.{Topic, Comment}
  alias Discuss.Repo

  def join("comments:" <> topic_id, _params, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Topic
      |> Repo.get(topic_id) #topic is a struct, get the topic with this id
      |> Repo.preload(comments: [:user]) #find all the comments with this topic_id / load up the assoc with topic_id

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)} # the 2nd arg should be a map!
  end

  def handle_in(_name, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    changeset = topic
      |> Ecto.build_assoc(:comments, user_id: user_id)
      |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        comment = Repo.preload(comment, [:user])
        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: "Please enter a valid comment"}}, socket}
    end
  end
end