defmodule DiscussWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias DiscussWeb.Router.Helpers

  def init(_params) do

  end

  def call(conn, _params) do
    if conn.assigns[:user] && conn.assigns.user.id do #let them pass if authorised or show error
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in.")
      |> redirect(to: Helpers.topic_path(conn, :index))
      |> halt()
    end
  end
end