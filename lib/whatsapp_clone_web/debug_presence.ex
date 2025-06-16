defmodule WhatsappCloneWeb.DebugPresence do
  require Logger
  alias WhatsappCloneWeb.Presence

  def log_all_user_presences do
    Logger.debug("=== LISTING ALL user:* PRESENCE ===")

    :pg.get_members(Phoenix.Tracker)  # works because Phoenix.Tracker runs via :pg
    |> Enum.each(fn pid ->
      send(pid, {:debug_presence, self()})
    end)

    tracked = Presence.list()

    tracked
    |> Enum.filter(fn {topic, _} -> String.starts_with?(topic, "user:") end)
    |> Enum.each(fn {topic, presences} ->
      Logger.debug("Topic: #{topic} -> Users: #{inspect(Map.keys(presences))}")
    end)
  end
end
