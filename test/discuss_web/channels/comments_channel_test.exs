defmodule DiscussWeb.CommentsChannelTest do
  use DiscussWeb.ChannelCase
  alias DiscussWeb.{UserSocket, CommentsChannel, Topic, Comment, User}
  alias Discuss.Repo

  setup do
    {:ok, topic} = %Topic{} |> Repo.insert()
    {:ok, user} = %User{email: "hello@gmail.com"} |> Repo.insert()
    {:ok, comment} = Repo.insert(
      %Comment{
        content: "A new comment",
        user: user,
        topic: topic
      }
    )
    token = Phoenix.Token.sign(DiscussWeb.Endpoint, "key", user.id)
    {:ok, socket} = connect(UserSocket, %{"token" => token})

    %{socket: socket, topic_id: topic.id, user: user, comment: comment}
  end

  test "user joins channel", %{socket: socket, topic_id: topic_id, comment: comment, user: user} do
    assert {:ok, data, socket} =
             subscribe_and_join(socket, CommentsChannel, "comments:#{topic_id}")
    content = comment.content
    assert %Topic{comments: [%{content: ^content, user: ^user}]} = socket.assigns.topic
    assert %{comments: [%{content: ^content, user: ^user}]} = data
  end

  test "handle_in handles valid and invalid content properly", %{socket: socket, topic_id: topic_id, user: user} do
    {:ok, _, socket} = subscribe_and_join(socket, CommentsChannel, "comments:#{topic_id}")
    valid_comment = %Comment{content: "A valid comment", user: user, topic_id: topic_id}
    invalid_comment = %Comment{content: "bad", user: user, topic_id: topic_id}
    user_id = user.id

    ref = push(socket, "comment:add", %{"content" => valid_comment.content})

    assert_reply(ref, :ok)

    ref = push(socket, "comment:add", %{"content" => invalid_comment.content})

    refute_reply(ref, :ok)

    comment_in_db = Repo.get_by(Comment, content: valid_comment.content)

    assert %Comment{content: "A valid comment", user_id: ^user_id, topic_id: topic_id} = comment_in_db

    event = "comments:#{topic_id}:new"
    assert_broadcast(^event, %{comment: valid_comment})

  end

end