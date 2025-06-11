defmodule WhatsappCloneWeb.SocialGraphChannel do
  use WhatsappCloneWeb, :channel

  def join("graph_updates:" <> _user_id, _payload, socket) do
    {:ok, socket}
  end
end
