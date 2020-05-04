defmodule DiscussWeb.TopicControllerTest do
  use DiscussWeb.ConnCase, async: true
  alias DiscussWeb.{Topic, User, Comment}
  alias Discuss.Repo
  @path_to_identicon "/mnt/c/Users/kintu/discuss/priv/static"
  @image_name "/images/Hello world.png"

  setup do
    {:ok, user1} = Repo.insert(%User{email: "hello@gmail.com"})
    {:ok, user2} = Repo.insert(%User{email: "hello1@gmail.com"})

    [user1: user1, user2: user2]
  end

  describe "GET /" do
    setup %{user1: user1} do
      {:ok, topic} = Repo.insert(
        %Topic{
          title: "A new topic",
          body: "Let's discuss this!",
          user: user1,
          identicon: @path_to_identicon <> @image_name
        }
      )
      [topic: topic]
    end

    test "Index fun returns a list of one topic with no edit/delete buttons for unauthorised users", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "A new topic"
      refute html_response(conn, 200) =~ "Delete"
      refute html_response(conn, 200) =~ "Edit"
    end

    test "Any user sees all topics with identicons", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ @image_name
    end

    test "Authorised user can see 'delete or edit' buttons", %{conn: conn, user1: user1} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> get("/")
      assert html_response(conn, 200) =~ "A new topic"
      assert html_response(conn, 200) =~ "Delete"
      assert html_response(conn, 200) =~ "Edit"
    end

    test "Authorised user cannot see 'delete or edit' buttons for another user's topic", %{conn: conn, user2: user2} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user2.id)
        |> get("/")
      assert html_response(conn, 200) =~ "A new topic"
      refute html_response(conn, 200) =~ "Delete"
      refute html_response(conn, 200) =~ "Edit"
    end

  end

  describe "POST /" do
    setup do
      topic = %{title: "Hello world", body: "Let's discuss!"}
      path = Application.get_env(:discuss, :path_to_identicon)
      on_exit(
        fn -> path_to_identicon = Path.wildcard("#{path}*.png")
              File.rm(path_to_identicon)
        end
      )
      [topic: topic, path: path]
    end

    test "A topic is created, identicon is saved to postgresql and hard drive",
         %{conn: conn, user1: user1, topic: topic, path: path} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> post("/", %{"topic" => topic})

      topic_in_db = Repo.get_by(Topic, title: "Hello world")

      assert html_response(conn, 302)
      assert topic_in_db
      assert topic_in_db.identicon == "#{path}/#{topic.title}.png"
    end
  end

  describe "GET /topic_id" do
    setup %{user1: user1, user2: user2} do
      topic = %Topic{
        title: "Hello world",
        user_id: user1.id,
        body: "Let's discuss!",
        identicon: @path_to_identicon <> @image_name
      }
      {:ok, topic} = Repo.insert(topic)
      comment = %Comment{content: "I'm leaving a comment", user_id: user2.id, topic_id: topic.id}
      {:ok, comment} = Repo.insert(comment)

      [topic: topic, comment: comment]
    end

    test "Show topic page with identicon to an authorised user",
         %{conn: conn, topic: topic, user1: user1} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> get("/#{topic.id}")

      assert html_response(conn, 200) =~ topic.title
      assert html_response(conn, 200) =~ @image_name
      assert html_response(conn, 200) =~ user1.email
    end

    test "Show topic page with identicon to an unauthorised user",
         %{conn: conn, topic: topic, user1: user1, comment: comment} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> get("/#{topic.id}")

      assert html_response(conn, 200) =~ topic.title
      assert html_response(conn, 200) =~ @image_name
      assert html_response(conn, 200) =~ user1.email
      refute html_response(conn, 200) =~ comment.content
    end
  end

  describe "GET /new" do
    test "Show new.html to an authorised user", %{conn: conn, user1: user1} do

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> get("/new")

        assert html_response(conn, 200) =~ "Please write what you&#39;d like to discuss here"

    end
  end

  describe "GET /:id/edit" do
    setup %{user1: user1} do
      topic = %Topic{
        title: "Hello world",
        user_id: user1.id,
        body: "Let's discuss!",
        identicon: @path_to_identicon <> @image_name
      }
      {:ok, topic} = Repo.insert(topic)

      [topic: topic]

      end
    test "Show edit.html to the topic's owner", %{conn: conn, user1: user1, topic: topic} do

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> get("/#{topic.id}/edit")

      assert html_response(conn, 200) =~ topic.title
      assert html_response(conn, 200) =~ topic.body |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
    end

    test "An authorised user cannot edit another user's topic", %{conn: conn, user2: user2, topic: topic} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user2.id)
        |> get("/#{topic.id}/edit")

        assert html_response(conn, 302)
        assert get_flash(conn, :error) == "You cannot edit or delete this topic"
    end
  end

  describe "PUT /:id" do
    setup %{user1: user1} do
      old_topic = %Topic{
        title: "Hello world",
        user_id: user1.id,
        body: "Let's discuss!",
        identicon: @path_to_identicon <> @image_name
      }
      {:ok, old_topic} = Repo.insert(old_topic)

      changed_topic = %{title: "Hello world again", body: "Let's discuss some more!"}

      [old_topic: old_topic, changed_topic: changed_topic]
    end

    test "An authorised user successfully updates their topic",
         %{conn: conn, old_topic: old_topic, changed_topic: changed_topic, user1: user1} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> put("/#{old_topic.id}", %{"topic" => changed_topic})

      assert get_flash(conn, :info) == "Topic Updated"

      topic_in_db = Repo.get(Topic, old_topic.id)

      assert topic_in_db.title == changed_topic.title
      assert topic_in_db.body == changed_topic.body

    end

    test "An authorised user cannot update another user's topic",
         %{conn: conn, user2: user2, old_topic: old_topic, changed_topic: changed_topic} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user2.id)
        |> put("/#{old_topic.id}", %{"topic" => changed_topic})

      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "You cannot edit or delete this topic"

    end

    test "An unauthorised user cannot update a topic",
         %{conn: conn, old_topic: old_topic, changed_topic: changed_topic} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put("/#{old_topic.id}", %{"topic" => changed_topic})

      assert html_response(conn, 302)
      assert get_flash(conn, :error) == "You must be logged in."

    end
  end

  describe "DELETE /:id" do
    setup %{user1: user1, user2: user2} do
      {:ok, topic} = Repo.insert(
        %Topic{
          title: "A new topic",
          body: "Let's discuss this!",
          user: user1,
          identicon: @path_to_identicon <> @image_name
        }
      )
      comment1 = %Comment{content: "I'm leaving a comment", user_id: user2.id, topic_id: topic.id}
      {:ok, comment1} = Repo.insert(comment1)

      comment2 = %Comment{content: "I'm leaving a comment, too", user_id: user1.id, topic_id: topic.id}
      {:ok, comment2} = Repo.insert(comment2)

      [topic: topic, comment1: comment1, comment2: comment2]
    end

    test "An authorised user can delete their topic", %{conn: conn, topic: topic, comment1: comment1, comment2: comment2, user1: user1} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> delete("/#{topic.id}")

      assert get_flash(conn, :info) == "Topic Deleted"
      assert html_response(conn, 302)
      refute Repo.get(Topic, topic.id)
      refute Repo.get(Comment, comment1.id)
      refute Repo.get(Comment, comment2.id)
    end

    test "An authorised user cannot delete someone else's topic", %{conn: conn, topic: topic, user2: user2} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user2.id)
        |> delete("/#{topic.id}")

      refute get_flash(conn, :info) == "Topic Deleted"
      assert get_flash(conn, :error) == "You cannot edit or delete this topic"
      assert html_response(conn, 302)
      assert Repo.get(Topic, topic.id)
    end

    test "An unauthorised user cannot delete someone else's topic", %{conn: conn, topic: topic} do
      conn =
        conn
        |> delete("/#{topic.id}")

      refute get_flash(conn, :info) == "Topic Deleted"
      assert get_flash(conn, :error) == "You must be logged in."
      assert html_response(conn, 302)
      assert Repo.get(Topic, topic.id)
    end
  end
end