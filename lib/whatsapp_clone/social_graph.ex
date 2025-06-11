# defmodule WhatsappClone.SocialGraph do
#   alias WhatsappClone.{Repo, Accounts.User, Friendships.Friendship}
#   alias Graph

#   @doc """
#   Builds a Graph of users and their friendships.
#   Returns a `Graph.t()`.
#   """
#   def build_graph do
#     graph = Graph.new(type: :undirected)

#     friendships =
#       Repo.all(Friendship)
#       |> Enum.filter(& &1.status == "accepted")

#     # Add edges between users
#     Enum.reduce(friendships, graph, fn %{user_id: u1, friend_id: u2}, g ->
#       g
#       |> Graph.add_vertex(u1)
#       |> Graph.add_vertex(u2)
#       |> Graph.add_edge(u1, u2)
#     end)
#   end

#   @doc """
#   Returns the list of direct friends (neighbors) for a user.
#   """
#   def friends_of(user_id) do
#     build_graph()
#     |> Graph.get_neighbors(user_id)
#   end

#   @doc """
#   Returns whether two users are connected in any path (direct or indirect).
#   """
#   def connected?(user1_id, user2_id) do
#     graph = build_graph()
#     Graph.reachable?(graph, user1_id, user2_id)
#   end

#   @doc """
#   Find shortest friendship path between two users.
#   """
#   def path(user1_id, user2_id) do
#     graph = build_graph()
#     Graph.dijkstra(graph, user1_id, user2_id)
#   end
# end

# defmodule WhatsappClone.SocialGraph do
#   use GenServer
#   import Ecto.Query
#   alias WhatsappClone.{Repo, Friendship, Friendships}
#   alias Graph

#   @name __MODULE__

#   # -- PUBLIC API --

#   def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: @name)

#   def get_graph, do: GenServer.call(@name, :get)

#   def friends_of(user_id), do: Graph.neighbors(get_graph(), user_id)

#   def connected?(u1, u2), do: Graph.reachable?(get_graph(), u1, u2)

#   def path(u1, u2), do: Graph.dijkstra(get_graph(), u1, u2)

#   def add_friend(u1, u2), do: GenServer.cast(@name, {:add_friend, u1, u2})

#   def rebuild, do: GenServer.cast(@name, :rebuild)

#   # -- SERVER CALLBACKS --

#   def init(_) do
#     graph = build_graph()
#     {:ok, graph}
#   end

#   def handle_call(:get, _from, graph), do: {:reply, graph, graph}

#   def handle_cast(:rebuild, _graph) do
#     new_graph = build_graph()
#     {:noreply, new_graph}
#   end

#   def handle_cast({:add_friend, u1, u2}, graph) do
#     graph =
#       graph
#       |> Graph.add_vertex(u1)
#       |> Graph.add_vertex(u2)
#       |> Graph.add_edge(u1, u2)

#     {:noreply, graph}
#   end

#   # -- INTERNALS --

#   defp build_graph do
#     Graph.new(type: :undirected)
#     |> add_friendships()
#   end

#   def remove_friend(u1, u2), do: GenServer.cast(@name, {:remove_friend, u1, u2})

#   def handle_cast({:remove_friend, u1, u2}, graph) do
#     graph =
#       graph
#       |> Graph.delete_edge(u1, u2)
#       |> Graph.delete_edge(u2, u1)

#     {:noreply, graph}
#   end


#   defp add_friendships(graph) do
#     Repo.all(from f in Friendship, where: f.status == "accepted")
#     |> Enum.reduce(graph, fn f, g ->
#       g
#       |> Graph.add_vertex(f.user_id)
#       |> Graph.add_vertex(f.friend_id)
#       |> Graph.add_edge(f.user_id, f.friend_id)
#     end)
#   end
# end


# defmodule WhatsappClone.SocialGraph do
#   use GenServer
#   import Ecto.Query
#   alias WhatsappClone.{Repo, Friendship, Friendships, User}
#   alias Graph
#   # alias WhatsappClone.Accounts.User

#   @name __MODULE__

#   # -- PUBLIC API --

#   def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: @name)

#   def get_graph, do: GenServer.call(@name, :get)

#   def friends_of(user_id), do: Graph.neighbors(get_graph(), user_id)

#   def connected?(u1, u2), do: Graph.reachable?(get_graph(), u1, u2)

#   def path(u1, u2), do: Graph.dijkstra(get_graph(), u1, u2)

#   def add_friend(u1, u2), do: GenServer.cast(@name, {:add_friend, u1, u2})

#   def rebuild, do: GenServer.cast(@name, :rebuild)

#   def remove_friend(u1, u2), do: GenServer.cast(@name, {:remove_friend, u1, u2})

#   @doc """
#   Returns users who are not already friends or have pending friend requests with the given user.
#   """


#   def list_discoverable_users(current_user_id) do
#     connected_ids = friends_of(current_user_id)

#     # Add self to avoid returning your own profile
#     exclude_ids = [current_user_id | connected_ids]

#     Repo.all(
#       from u in User,
#         where: u.id not in ^exclude_ids,
#         select: %{
#           id: u.id,
#           username: u.username,
#           display_name: u.display_name,
#           avatar_data: fragment("encode(COALESCE(?, ''), 'base64')", u.avatar_data)
#         }
#     )
#   end



#   # -- SERVER CALLBACKS --

#   def init(_) do
#     graph = build_graph()
#     {:ok, graph}
#   end

#   def handle_call(:get, _from, graph), do: {:reply, graph, graph}

#   def handle_cast(:rebuild, _graph) do
#     new_graph = build_graph()
#     {:noreply, new_graph}
#   end

#   def handle_cast({:add_friend, u1, u2}, graph) do
#     graph =
#       graph
#       |> Graph.add_vertex(u1)
#       |> Graph.add_vertex(u2)
#       |> Graph.add_edge(u1, u2)

#     {:noreply, graph}
#   end

#   def handle_cast({:remove_friend, u1, u2}, graph) do
#     graph =
#       graph
#       |> Graph.delete_edge(u1, u2)
#       |> Graph.delete_edge(u2, u1)

#     {:noreply, graph}
#   end

#   # -- INTERNALS --

#   defp build_graph do
#     Graph.new(type: :undirected)
#     |> add_friendships()
#   end

#   defp add_friendships(graph) do
#     Repo.all(from f in Friendship, where: f.status == "accepted")
#     |> Enum.reduce(graph, fn f, g ->
#       g
#       |> Graph.add_vertex(f.user_id)
#       |> Graph.add_vertex(f.friend_id)
#       |> Graph.add_edge(f.user_id, f.friend_id)
#     end)
#   end
# end


defmodule WhatsappClone.SocialGraph do
  use GenServer
  import Ecto.Query
  alias WhatsappClone.{Repo, Friendship, User}
  alias Graph

  @name __MODULE__

  # -- PUBLIC API --

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: @name)

  def get_graph, do: GenServer.call(@name, :get)

  def friends_of(user_id), do: Graph.neighbors(get_graph(), user_id)

  def connected?(u1, u2), do: u2 in Graph.reachable(get_graph(), u1)



  def path(u1, u2), do: Graph.dijkstra(get_graph(), u1, u2)

  def add_friend(u1, u2), do: GenServer.cast(@name, {:add_friend, u1, u2})

  def rebuild, do: GenServer.cast(@name, :rebuild)

  def remove_friend(u1, u2), do: GenServer.cast(@name, {:remove_friend, u1, u2})

  @doc """
  Returns users who are not already friends or have pending friend requests with the given user.
  """
  def list_discoverable_users(current_user_id) do
    connected_ids = friends_of(current_user_id)
    exclude_ids = [current_user_id | connected_ids]

    Repo.all(
      from u in User,
        where: u.id not in ^exclude_ids,
        select: %{
          id: u.id,
          username: u.username,
          display_name: u.display_name,
          avatar_data: fragment("encode(COALESCE(?, ''), 'base64')", u.avatar_data)
        }
    )
  end

  def mutual_friends(user1_id, user2_id) do
    friends1 = MapSet.new(friends_of(user1_id))
    friends2 = MapSet.new(friends_of(user2_id))

    mutual_ids = MapSet.intersection(friends1, friends2) |> MapSet.to_list()

    Repo.all(
      from u in User,
        where: u.id in ^mutual_ids,
        select: %{
          id: u.id,
          username: u.username,
          display_name: u.display_name,
          avatar_data: fragment("encode(COALESCE(?, ''), 'base64')", u.avatar_data)
        }
    )
  end

  # -- SERVER CALLBACKS --

  def init(_) do
    {:ok, build_graph()}
  end

  def handle_call(:get, _from, graph), do: {:reply, graph, graph}

  def handle_cast(:rebuild, _graph), do: {:noreply, build_graph()}

  def handle_cast({:add_friend, u1, u2}, graph) do
    graph =
      graph
      |> Graph.add_vertex(u1)
      |> Graph.add_vertex(u2)
      |> Graph.add_edge(u1, u2)

    {:noreply, graph}
  end

  def handle_cast({:remove_friend, u1, u2}, graph) do
    graph =
      graph
      |> Graph.delete_edge(u1, u2)
      |> Graph.delete_edge(u2, u1)

    {:noreply, graph}
  end

  # -- INTERNALS --

  defp build_graph do
    graph = Graph.new(type: :undirected)

    friendships =
      Repo.all(from f in Friendship, where: f.status == "accepted")

    Enum.reduce(friendships, graph, fn f, g ->
      g
      |> Graph.add_vertex(f.user_id)
      |> Graph.add_vertex(f.friend_id)
      |> Graph.add_edge(f.user_id, f.friend_id)
    end)
  end
end
