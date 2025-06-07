# defmodule WhatsappCloneWeb.Router do
#   use WhatsappCloneWeb, :router

#   pipeline :api do
#     plug :accepts, ["json"]
#   end

#   pipeline :auth do
#     plug WhatsappCloneWeb.Plugs.AuthPlug
#   end



#   scope "/api", WhatsappCloneWeb do
#     pipe_through :api

#     # Auth
#     post "/register", AuthController, :register
#     post "/login", AuthController, :login

#     # Users

#     get "/users/search", UserController, :search
#     get "/users/:id", UserController, :show
#     get "/users/:id/conversations", ConversationController, :index

#     # Devices
#     post "/devices", DeviceController, :create
#     delete "/devices/:id", DeviceController, :delete

#     # Conversations
#     post "/conversations", ConversationController, :create
#     get "/conversations", ConversationController, :list_for_current_user
#     patch "/conversations/:id", ConversationController, :update

#     # Messages
#     post "/conversations/:conversation_id/messages", MessageController, :create
#     get "/conversations/:conversation_id/messages", MessageController, :index

#     # Message statuses
#     patch "/messages/:message_id/status", MessageStatusController, :update

#     # (Optional) Conversation members
#     # post "/conversations/:conversation_id/members", ConversationMemberController, :create
#     # delete "/conversations/:conversation_id/members/:user_id", ConversationMemberController, :delete
#     # patch "/conversations/:conversation_id/members/:user_id", ConversationMemberController, :update
#   end

#   if Application.compile_env(:whatsapp_clone, :dev_routes) do
#     import Phoenix.LiveDashboard.Router

#     scope "/dev" do
#       pipe_through [:fetch_session, :protect_from_forgery]
#       live_dashboard "/dashboard", metrics: WhatsappCloneWeb.Telemetry
#       forward "/mailbox", Plug.Swoosh.MailboxPreview
#     end
#   end
# end

defmodule WhatsappCloneWeb.Router do
  use WhatsappCloneWeb, :router

  # Define API pipeline
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Define authenticated API pipeline
  pipeline :auth_api do
    plug :accepts, ["json"]
    plug WhatsappCloneWeb.Plugs.AuthPlug
  end

  # Public API (no auth required)
  scope "/api", WhatsappCloneWeb do
    pipe_through :api

    # Authentication
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  # Protected API (auth required)
  scope "/api", WhatsappCloneWeb do
    pipe_through :auth_api

    # Users
    get "/users/search", UserController, :search
    get "/users/:id", UserController, :show
    get "/users/:id/conversations", ConversationController, :index

    # Devices
    post "/devices", DeviceController, :create
    delete "/devices/:id", DeviceController, :delete

    # Conversations
    post "/conversations", ConversationController, :create
    get "/conversations", ConversationController, :list_for_current_user
    patch "/conversations/:id", ConversationController, :update
    patch "/conversations/:id/admins", ConversationController, :update_admins
    delete "/conversations/:id", ConversationController, :delete

    # Messages
    post "/conversations/:conversation_id/messages", MessageController, :create
    get "/conversations/:conversation_id/messages", MessageController, :index

    # Message statuses
    patch "/messages/:message_id/status", MessageStatusController, :update
  end

  # Dev dashboard (only enabled in dev)
  if Application.compile_env(:whatsapp_clone, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: WhatsappCloneWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
