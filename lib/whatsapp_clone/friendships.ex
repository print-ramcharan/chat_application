# defmodule WhatsappClone.Friendships do
#   import Ecto.Query
#   alias WhatsappClone.{Repo, Friendship, User}

#   def send_request(user_id, friend_id) do
#     %Friendship{}
#     |> Friendship.changeset(%{user_id: user_id, friend_id: friend_id, status: "pending"})
#     |> Repo.insert()
#   end

#   # def accept_request(user_id, friend_id) do
#   #   from(f in Friendship,
#   #     where: f.user_id == ^friend_id and f.friend_id == ^user_id and f.status == "pending"
#   #   )
#   #   |> Repo.one()
#   #   |> case do
#   #     nil -> {:error, "No pending request"}
#   #     request ->
#   #       Repo.transaction(fn ->
#   #         Repo.update!(Ecto.Changeset.change(request, status: "accepted"))

#   #         %Friendship{}
#   #         |> Friendship.changeset(%{user_id: user_id, friend_id: friend_id, status: "accepted"})
#   #         |> Repo.insert!()
#   #       end)

#   #       {:ok, "Friend request accepted"}
#   #   end
#   # end

#   def accept_request(user_id, friend_id) do
#     from(f in Friendship,
#       where: f.user_id == ^friend_id and f.friend_id == ^user_id and f.status == "pending"
#     )
#     |> Repo.one()
#     |> case do
#       nil ->
#         {:error, "No pending request"}

#       request ->
#         Repo.transaction(fn ->
#           # Accept the existing request (friend_id sent to user_id)
#           Repo.update!(Ecto.Changeset.change(request, status: "accepted"))

#           # Create reciprocal friendship (user_id to friend_id)
#           %Friendship{}
#           |> Friendship.changeset(%{
#             user_id: user_id,
#             friend_id: friend_id,
#             status: "accepted"
#           })
#           |> Repo.insert!()

#           # Realtime: Update in-memory graph
#           WhatsappClone.SocialGraph.add_friend(user_id, friend_id)

#           # Realtime: Broadcast update
#           WhatsappClone.SocialGraphNotifier.graph_updated(user_id, friend_id)
#         end)

#         {:ok, "Friend request accepted"}
#     end
#   end

#   def list_pending_requests(user_id) do
#     from(f in Friendship,
#       where: f.friend_id == ^user_id and f.status == "pending",
#       join: u in assoc(f, :user),
#       select: %{id: u.id, username: u.username, display_name: u.display_name}
#     )
#     |> Repo.all()
#   end

#   def list_friends(user_id) do
#     from(f in Friendship,
#       where: f.user_id == ^user_id and f.status == "accepted",
#       join: u in assoc(f, :friend),
#       select: %{id: u.id, username: u.username, display_name: u.display_name}
#     )
#     |> Repo.all()
#   end

#   def mutual_friends(user1_id, user2_id) do
#     user1_friends = from(f in Friendship,
#       where: f.user_id == ^user1_id and f.status == "accepted",
#       select: f.friend_id
#     )

#     from(f in Friendship,
#       where: f.user_id == ^user2_id and f.status == "accepted" and f.friend_id in subquery(user1_friends),
#       join: u in assoc(f, :friend),
#       select: %{id: u.id, username: u.username, display_name: u.display_name}
#     )
#     |> Repo.all()
#   end

# end

# defmodule WhatsappClone.Friendships do
#   import Ecto.Query
#   alias WhatsappClone.{Repo, Friendship, User, SocialGraph, SocialGraphNotifier}

#   # Send request - still writes to DB
#   def send_request(user_id, friend_id) do
#     %Friendship{}
#     |> Friendship.changeset(%{user_id: user_id, friend_id: friend_id, status: "pending"})
#     |> Repo.insert()
#   end

#   # Accept request - now also updates in-memory graph and notifies clients
#   def accept_request(user_id, friend_id) do
#     from(f in Friendship,
#       where: f.user_id == ^friend_id and f.friend_id == ^user_id and f.status == "pending"
#     )
#     |> Repo.one()
#     |> case do
#       nil ->
#         {:error, "No pending request"}

#       request ->
#         Repo.transaction(fn ->
#           Repo.update!(Ecto.Changeset.change(request, status: "accepted"))

#           %Friendship{}
#           |> Friendship.changeset(%{user_id: user_id, friend_id: friend_id, status: "accepted"})
#           |> Repo.insert!()

#           # Update in-memory graph
#           SocialGraph.add_friend(user_id, friend_id)

#           # Notify both users
#           SocialGraphNotifier.graph_updated(user_id, friend_id)
#         end)

#         {:ok, "Friend request accepted"}
#     end
#   end

#   # Get pending requests from DB - graph not needed
#   def list_pending_requests(user_id) do
#     from(f in Friendship,
#       where: f.friend_id == ^user_id and f.status == "pending",
#       join: u in assoc(f, :user),
#       select: %{id: u.id, username: u.username, display_name: u.display_name}
#     )
#     |> Repo.all()
#   end

#   # ✅ List friends using the in-memory graph
#   def list_friends(user_id) do
#     friend_ids = SocialGraph.friends_of(user_id)

#     from(u in User,
#       where: u.id in ^friend_ids,
#       select: %{id: u.id, username: u.username, display_name: u.display_name}
#     )
#     |> Repo.all()
#   end

#   # ✅ Mutual friends using in-memory graph intersection
#   def mutual_friends(user1_id, user2_id) do
#     friends1 = MapSet.new(SocialGraph.friends_of(user1_id))
#     friends2 = MapSet.new(SocialGraph.friends_of(user2_id))
#     mutual_ids = MapSet.intersection(friends1, friends2) |> MapSet.to_list()

#     from(u in User,
#       where: u.id in ^mutual_ids,
#       select: %{id: u.id, username: u.username, display_name: u.display_name}
#     )
#     |> Repo.all()
#   end
# end

defmodule WhatsappClone.Friendships do
  import Ecto.Query
  # alias WhatsappClone.Repo

  alias WhatsappClone.{Repo, Friendship, User, SocialGraph, SocialGraphNotifier}

  # def send_request(user_id, friend_id) do
  #   %Friendship{}
  #   |> Friendship.changeset(%{
  #     user_id: user_id,
  #     friend_id: friend_id,
  #     status: "pending"
  #   })
  #   |> Repo.insert()
  # end
  # def send_request(user_id, friend_id) when user_id != friend_id do
  #   attrs = %{user_id: user_id, friend_id: friend_id, status: "pending"}

  #   %Friendship{}
  #   |> Friendship.changeset(attrs)
  #   |> Repo.insert(
  #     conflict_target: [:user_id, :friend_id],
  #     on_conflict: :nothing
  #   )
  # end

  def send_request(user_id, friend_id) when user_id != friend_id do
    attrs = %{user_id: user_id, friend_id: friend_id, status: "pending"}

    %Friendship{}
    |> Friendship.changeset(attrs)
    |> Repo.insert(
      conflict_target: [:user_id, :friend_id],
      on_conflict: :nothing
    )
  end


  def accept_request(user_id, friend_id) do
    from(f in Friendship,
      where: f.user_id == ^friend_id and f.friend_id == ^user_id and f.status == "pending"
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, "No pending request"}

      request ->
        Repo.transaction(fn ->
          Repo.update!(Ecto.Changeset.change(request, status: "accepted"))

          %Friendship{}
          |> Friendship.changeset(%{
            user_id: user_id,
            friend_id: friend_id,
            status: "accepted"
          })
          |> Repo.insert!()

          SocialGraph.add_friend(user_id, friend_id)
          SocialGraph.add_friend(friend_id, user_id) # <- optional: for bidirectional

          SocialGraphNotifier.graph_updated(user_id, friend_id)
        end)

        {:ok, "Friend request accepted"}
    end
  end

  def list_pending_requests(user_id) do
    from(f in Friendship,
      where: f.friend_id == ^user_id and f.status == "pending",
      join: u in assoc(f, :user),
      select: %{id: u.id, username: u.username, display_name: u.display_name}
    )
    |> Repo.all()
  end

  # def list_friends(user_id) do
  #   friend_ids = SocialGraph.friends_of(user_id)

  #   from(u in User,
  #     where: u.id in ^friend_ids,
  #     select: %{id: u.id, username: u.username, display_name: u.display_name}
  #   )
  #   |> Repo.all()
  # end

  def list_friends(user_id) do
    friend_ids = SocialGraph.friends_of(user_id)

    from(u in User,
      where: u.id in ^friend_ids,
      select: %{
        id: u.id,
        username: u.username,
        display_name: u.display_name,
        avatar_data: fragment("encode(COALESCE(?, ''), 'base64')", u.avatar_data)
      }
    )
    |> Repo.all()
  end

  def mutual_friends(user1_id, user2_id) do
    friends1 = MapSet.new(SocialGraph.friends_of(user1_id))
    friends2 = MapSet.new(SocialGraph.friends_of(user2_id))

    IO.inspect(friends1, label: "Friends of #{user1_id}")
    IO.inspect(friends2, label: "Friends of #{user2_id}")

    mutual_ids = MapSet.intersection(friends1, friends2) |> MapSet.to_list()
    IO.inspect(mutual_ids, label: "Mutual Friend IDs")

    from(u in User,
      where: u.id in ^mutual_ids,
      select: %{
        id: u.id,
        username: u.username,
        display_name: u.display_name,
        avatar_data: fragment("encode(COALESCE(?, ''), 'base64')", u.avatar_data)
      }
    )
    |> Repo.all()
  end


  # def list_discoverable_users(current_user_id) do
  #   uuid = Ecto.UUID.cast!(current_user_id)

  #   from u in User,
  #     where: u.id != ^uuid,
  #     where: u.id not in subquery(friends_and_pending_ids(uuid)),
  #     select: %{id: u.id, username: u.username, profile_picture: u.avatar_data}
  # end
  def list_discoverable_users(current_user_id) do
    uuid = Ecto.UUID.cast!(current_user_id)


    from u in User,
      where: u.id != ^uuid,
      where: u.id not in subquery(friends_and_pending_ids(uuid)),
      select: %{
        id: u.id,
        username: u.username,
        display_name: u.display_name,
        avatar_data: fragment("encode(COALESCE(?, ''), 'base64')", u.avatar_data)
      }
  end




  defp friends_and_pending_ids(uuid) do
    from f in Friendship,
      where: f.status in ["pending", "accepted"] and
             (f.user_id == ^uuid or f.friend_id == ^uuid),
      select: fragment(
        "CASE WHEN ? = ? THEN ? ELSE ? END",
        f.user_id, ^uuid, f.friend_id, f.user_id
      )
  end


  # def delete_friend(user_id, friend_id) do
  #   Repo.transaction(fn ->
  #     from(f in Friendship,
  #       where:
  #         (f.user_id == ^user_id and f.friend_id == ^friend_id) or
  #           (f.user_id == ^friend_id and f.friend_id == ^user_id)
  #     )
  #     |> Repo.delete_all()

  #     SocialGraph.remove_friend(user_id, friend_id)
  #     SocialGraph.remove_friend(friend_id, user_id)

  #     SocialGraphNotifier.graph_updated(user_id, friend_id)
  #   end)

  #   :ok
  # rescue
  #   _ -> {:error, "Unable to unfriend"}
  # end

  def delete_friend(user_id, friend_id) do
    result =
      Repo.transaction(fn ->
        {count, _} =
          from(f in Friendship,
            where:
              (f.user_id == ^user_id and f.friend_id == ^friend_id) or
                (f.user_id == ^friend_id and f.friend_id == ^user_id)
          )
          |> Repo.delete_all()

        if count > 0 do
          SocialGraph.remove_friend(user_id, friend_id)
          SocialGraph.remove_friend(friend_id, user_id)

          SocialGraphNotifier.graph_updated(user_id, friend_id)
          :ok
        else
          Repo.rollback("No such friendship found")
        end
      end)

    case result do
      {:ok, :ok} -> :ok
      {:error, _} -> {:error, "Unable to unfriend"}
    end
  end


end
