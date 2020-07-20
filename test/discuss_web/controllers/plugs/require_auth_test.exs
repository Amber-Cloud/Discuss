defmodule DiscussWeb.Plugs.RequireAuthTest do
  use DiscussWeb.ConnCase, async: true

  alias Discuss.Repo
  alias DiscussWeb.User
  alias DiscussWeb.Plugs.RequireAuth

  test "call fun assigns existing user to conn", %{conn: conn} do

    {:ok, user} = %User{email: "hello@gmail.com"} |> Repo.insert()

    conn =
      conn
      |> merge_assigns([user: user])
      |> RequireAuth.call(%{})

    assert conn.assigns.user.id == user.id
  end

  test "call fun puts flash when no user", %{conn: conn} do

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> fetch_flash()
      |> RequireAuth.call(%{})

    assert get_flash(conn, :error) == "You must be logged in."
    assert conn.status == 302
  end
end