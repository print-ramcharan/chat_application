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
    post "/refresh_token", AuthController, :refresh
    post "/verify_token", AuthController, :verify
  end

  # Protected API (auth required)
  scope "/api", WhatsappCloneWeb do
    pipe_through :auth_api

    # Users
    get "/users/search", UserController, :search
    get "/users/:id", UserController, :show
    get "/users/:id/conversations", ConversationController, :index
    patch "/users/avatar", UserController, :avatar
    patch "/users/fcm_token", UserController, :update_fcm_token
    # patch "/users/is_online"


    # Devices
    post "/devices", DeviceController, :create
    delete "/devices/:id", DeviceController, :delete

    # Conversations
    post "/conversations", ConversationController, :create

    post "/conversations/:id/remove_member", ConversationController, :remove_member
    patch "/conversations/:id/add_member", ConversationController, :add_member

    post "/messages/:message_id/reply", MessageController, :reply

    get "/conversations", ConversationController, :list_for_current_user
    get "/conversations/:id/members", ConversationController, :members
    get "/conversations/:id/details", ConversationController, :details
    get "/conversations/:id/avatar", ConversationController, :avatar

    patch "/conversations/:id", ConversationController, :update
    patch "/conversations/:id/admins", ConversationController, :update_admins
    # patch "/conversations/:id/avatar", ConversationController, :update_avatar

    # delete "/conversations/:id", ConversationController, :delete
    # post "/conversations/:id/remove_member", ConversationController, :remove_member

    #Friendship

    # get "/friendships/mutual/:other_user_id", FriendshipController, :mutual_friends

    post "/friendships/send", FriendshipController, :send_request
    post "/friendships/accept", FriendshipController, :accept_request
    get "/friendships/pending", FriendshipController, :pending_requests
    get "/friendships/friends", FriendshipController, :list_friends
    get "/friendships/mutual/:user_id", FriendshipController, :mutual_friends
    get "/friendships/discover", FriendshipController, :discover_users
    delete "/friendships", FriendshipController, :delete_friend



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
