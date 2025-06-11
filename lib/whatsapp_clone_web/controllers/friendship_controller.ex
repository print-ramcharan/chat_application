# defmodule WhatsappCloneWeb.FriendshipController do
#   use WhatsappCloneWeb, :controller
#   alias WhatsappClone.Friendships

#   action_fallback WhatsappCloneWeb.FallbackController

#   def send_request(conn, %{"friend_id" => friend_id}) do
#     user_id = conn.assigns[:user_id]
#     case Friendships.send_request(user_id, friend_id) do
#       {:ok, _} -> json(conn, %{message: "Request sent"})
#       {:error, changeset} -> conn |> put_status(:bad_request) |> json(%{error: changeset})
#     end
#   end
#   # def accept_request(conn, %{"friend_id" => friend_id}) do
#   #   user_id = conn.assigns[:user_id]

#   #   case Friendships.accept_request(user_id, friend_id) do
#   #     {:ok, _friendship} ->
#   #       # Trigger the graph update
#   #       WhatsappClone.SocialGraphNotifier.graph_updated(user_id, friend_id)

#   #       json(conn, %{message: "Request accepted"})

#   #     {:error, reason} ->
#   #       conn
#   #       |> put_status(:bad_request)
#   #       |> json(%{error: reason})
#   #   end
#   # end
#   def accept_request(conn, %{"friend_id" => friend_id}) do
#     user_id = conn.assigns[:user_id]

#     case Friendships.accept_request(user_id, friend_id) do
#       {:ok, _friendship} ->
#         json(conn, %{message: "Request accepted"})

#       {:error, reason} ->
#         conn
#         |> put_status(:bad_request)
#         |> json(%{error: reason})
#     end
#   end


#   def pending_requests(conn, _params) do
#     user_id = conn.assigns[:user_id]
#     requests = Friendships.list_pending_requests(user_id)
#     json(conn, %{pending_requests: requests})
#   end

#   def mutual_friends(conn, %{"other_user_id" => other_id}) do
#     user_id = conn.assigns[:user_id]
#     friends = Friendships.mutual_friends(user_id, other_id)
#     json(conn, %{mutual_friends: friends})
#   end


#   def list_friends(conn, _params) do
#     user_id = conn.assigns[:user_id]
#     friends = Friendships.list_friends(user_id)
#     json(conn, %{friends: friends})
#   end
# end


defmodule WhatsappCloneWeb.FriendshipController do
  use WhatsappCloneWeb, :controller
  alias WhatsappClone.Friendships
  alias WhatsappClone.Repo


  action_fallback WhatsappCloneWeb.FallbackController

  def send_request(conn, %{"friend_id" => friend_id}) do
    user_id = conn.assigns[:user_id]

    case Friendships.send_request(user_id, friend_id) do
      {:ok, _} ->
        json(conn, %{message: "Request sent"})

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: Ecto.Changeset.traverse_errors(changeset, &to_string/1)})
    end
  end

    def list_friends(conn, _params) do
    user_id = conn.assigns[:user_id]
    friends = Friendships.list_friends(user_id)
    json(conn, %{friends: friends})
  end
  def accept_request(conn, %{"friend_id" => friend_id}) do
    user_id = conn.assigns[:user_id]

    case Friendships.accept_request(user_id, friend_id) do
      {:ok, _} ->
        json(conn, %{message: "Request accepted"})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def pending_requests(conn, _params) do
    user_id = conn.assigns[:user_id]
    requests = Friendships.list_pending_requests(user_id)
    json(conn, %{pending_requests: requests})
  end

  def mutual_friends(conn, %{"user_id" => other_id}) do
    user_id = conn.assigns[:user_id]
    friends = Friendships.mutual_friends(user_id, other_id)
    json(conn, %{mutual_friends: friends})
  end

  # def discover_users(conn, _params) do
  #   user_id = conn.assigns[:user_id]
  #   users = WhatsappClone.Friendships.list_discoverable_users(user_id) |> Repo.all()
  #   json(conn, users)
  # end


  def discover_users(conn, _params) do
    user_id_str = conn.assigns[:user_id]

    case Ecto.UUID.cast(user_id_str) do
      {:ok, uuid} ->
        users = WhatsappClone.SocialGraph.list_discoverable_users(uuid)
        json(conn, users)

      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid user ID"})
    end
  end

  # def discover_users(conn, _params) do
  #   current_user_id = conn.assigns[:user_id]

  #   users =
  #     Friendships.list_discoverable_users(current_user_id)
  #     |> Repo.all()

  #   json(conn, users)
  # end

  def delete_friend(conn, %{"friend_id" => friend_id}) do
    user_id = conn.assigns[:user_id]

    case WhatsappClone.Friendships.delete_friend(user_id, friend_id) do
      :ok ->
        json(conn, %{message: "Unfriended successfully"})

        WhatsappClone.SocialGraph.remove_friend(user_id, friend_id)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

end
