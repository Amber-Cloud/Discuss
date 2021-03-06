defmodule DiscussWeb.Plugs.SetUser do
  import Plug.Conn

  alias Discuss.Repo
  alias DiscussWeb.User

  def init(_params) do

  end

  def call(conn, _params) do #params are the return value of the init fun, so we don't use params
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) -> #if user_id is defined (then true) and the right part returns a user, the whole exp is truthy and returns the second part
        assign(conn, :user, user)
      true ->
        assign(conn, :user, %{id: nil})
    end

  end
end