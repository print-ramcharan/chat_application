defmodule WhatsappClone.SocialGraphNotifier do
  alias WhatsappCloneWeb.Endpoint

  def graph_updated(user_id, friend_id) do
    Endpoint.broadcast("graph_updates:#{user_id}", "graph_updated", %{friend_id: friend_id})
    Endpoint.broadcast("graph_updates:#{friend_id}", "graph_updated", %{friend_id: user_id})
  end
end
