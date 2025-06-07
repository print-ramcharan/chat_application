defmodule WhatsappCloneWeb.Presence do
  use Phoenix.Presence,
    otp_app: :whatsapp_clone,
    pubsub_server: WhatsappClone.PubSub
end
