defmodule DiscussWeb.Plugs.SetUserTest do
  use DiscussWeb.ConnCase, async: true

  alias Discuss.Repo
  alias DiscussWeb.User

  test "call fun assigns existing user to conn", %{conn: conn} do

    {:ok, user} = %User{email: "hello@gmail.com"} |> Repo.insert()

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:user_id, user.id)
      |> get("/")

    assert conn.assigns.user.id == user.id
  end

  test "call fun sets user as nil in conn if user doesn't exist", %{conn: conn} do
    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:user_id, nil)
      |> get("/")

    assert conn.assigns.user.id == nil
  end

end