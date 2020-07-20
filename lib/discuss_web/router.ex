defmodule DiscussWeb.Router do
  use DiscussWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DiscussWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DiscussWeb do
    pipe_through :browser

#    get "/", TopicController, :index #bending the conventions
#    get "/topics/new", TopicController, :new
#    post "/topics", TopicController, :create
#    get "/topics/:id/edit", TopicController, :edit
#    put "/topics/:id", TopicController, :update
#    delete "/topics/:id", TopicController, :delete

    resources "/", TopicController
  end

  scope "/auth", DiscussWeb do
    pipe_through :browser

    put "/signout", AuthController, :sign_out
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback

  end

end
