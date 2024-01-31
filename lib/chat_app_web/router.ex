defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :api do
    plug CORSPlug, origin: ["http://localhost:8080", "http://192.168.1.7:8080"]
    plug :accepts, ["json"]
  end

  scope "/api", ChatAppWeb do
    pipe_through :api

    post "/chats/:id/join", ChatController, :join
    post "/chats", ChatController, :create
    options "/chats", ChatController, :options
    get "/chats", ChatController, :index
    get "/chats/:id", ChatController, :show
    get "/chats/:id/messages", ChatController, :get_messages
  end
end
