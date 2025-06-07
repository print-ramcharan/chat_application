defmodule WhatsappClone.Repo do
  use Ecto.Repo,
    otp_app: :whatsapp_clone,
    adapter: Ecto.Adapters.Postgres
end
