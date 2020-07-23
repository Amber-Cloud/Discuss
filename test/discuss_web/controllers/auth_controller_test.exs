defmodule DiscussWeb.AuthControllerTest do
  use DiscussWeb.ConnCase, async: true
  alias DiscussWeb.{AuthController, User}
  alias Discuss.Repo

  test "PUT/auth/signout fun removes cookies", %{conn: conn} do
    user_id = 3

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> put_session(:user_id, user_id)
      |> put("/auth/signout")

      assert conn.private.plug_session_info == :drop
      assert html_response(conn, 302)
  end

  test "GET/auth/:provider/callback fun signs in a new valid user", %{conn: conn} do
    auth = %Ueberauth.Auth{
      provider: :github,
      info: %{
        email: "john.doe@example.com"
      },
      credentials: %{token: "sldfjsdhf;ashg;agh;a"}
    }

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> fetch_flash()
      |> assign(:ueberauth_auth, auth)
      |> AuthController.callback(%{})

      assert html_response(conn, 302)
      assert get_session(conn, :user_id)
      assert get_flash(conn, :info) == "Welcome back!"
  end

  test "GET/auth/:provider/callback fun signs in an existing valid user", %{conn: conn} do
    auth = %Ueberauth.Auth{
      provider: :github,
      info: %{
        email: "john.doe@example.com"
      },
      credentials: %{token: "sldfjsdhf;ashg;agh;a"}
    }

    {:ok, _user} = %User{email: "john.doe@example.com"} |> Repo.insert()

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> fetch_flash()
      |> assign(:ueberauth_auth, auth)
      |> AuthController.callback(%{})

    assert html_response(conn, 302)
    assert get_session(conn, :user_id)
    assert get_flash(conn, :info) == "Welcome back!"
  end

  test "GET/auth/:provider/callback fun puts flash :error if sth goes wrong", %{conn: conn} do
    auth = %Ueberauth.Auth{
      provider: :github,
      info: %{
        email: "john.doe@example.com"
      },
      credentials: %{token: nil}
    }

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> fetch_flash()
      |> assign(:ueberauth_auth, auth)
      |> AuthController.callback(%{})

    assert html_response(conn, 302)
    refute get_session(conn, :user_id)
    assert get_flash(conn, :error) == "Error signing in"
  end
end

