defmodule DiscussWeb.TopicControllerTest do
  use DiscussWeb.ConnCase, async: true
  alias DiscussWeb.{Topic, User}
  alias Discuss.Repo

  describe "GET index" do
    setup do
      {:ok, user1} = Repo.insert(%User{email: "hello@gmail.com"})
      {:ok, user2} = Repo.insert(%User{email: "hello1@gmail.com"})
      {:ok, topic} = Repo.insert(%Topic{title: "A new topic", body: "Let's discuss this!", user: user1})
      [topic: topic, user1: user1, user2: user2]
    end

    test "Index fun returns a list of one topic with no edit/delete buttons for unauthorised users", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "A new topic"
      refute html_response(conn, 200) =~ "Delete"
      refute html_response(conn, 200) =~ "Edit"
    end

    test "Authorised user can delete or edit their topics", %{conn: conn, user1: user1} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> put_session(:user_id, user1.id)
        |> get("/")
      assert html_response(conn, 200) =~ "A new topic"
      assert html_response(conn, 200) =~ "Delete"
      assert html_response(conn, 200) =~ "Edit"
    end

    test "Authorised user cannot delete or edit other user's topics", %{conn: conn, user2: user2} do
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

  describe "POST create" do
    setup do
      {:ok, user1} = Repo.insert(%User{email: "hello@gmail.com"})
      topic = %{title: "Hello world", body: "Let's discuss!"}
      path = Application.get_env(:discuss, :path_to_identicon)
      on_exit(
        fn -> path_to_identicon = Path.wildcard("#{path}*.png")
              File.rm(path_to_identicon)
        end
      )
      [topic: topic, user1: user1, path: path]
    end

    test "A topic is created, identicon is saved to postgresql and hard drive", %{conn: conn, user1: user1, topic: topic, path: path} do
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

end
