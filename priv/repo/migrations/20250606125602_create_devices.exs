defmodule WhatsappClone.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :device_name, :text, null: false
      add :public_key, :text, null: false
      add :inserted_at, :timestamptz, null: false, default: fragment("now()")
    end
  end
end
