defmodule DiscussWeb.Plugs.SetUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Discuss.Repo
  alias DiscussWeb.User

  def init(_params) do

  end

  def call(conn, _params) do #params are the return value of the init fun
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) -> #if user_id is defined (then true) and the right part returns a user, the whole exp is truthy
        assign(conn, :user, user)
      true ->
        assign(conn, :user, nil)
    end

  end
end