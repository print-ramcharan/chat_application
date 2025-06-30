defmodule WhatsappClone.PresenceTracker do
  alias WhatsappCloneWeb.Presence

  def online_in_conversation?(user_id, conversation_id) do
    Presence.list("chat:#{conversation_id}")
    |> Map.has_key?(user_id)
  end

  def online_in_personal_channel?(user_id) do
    Presence.list("user:#{user_id}")
    |> Map.has_key?(user_id)
  end
end
