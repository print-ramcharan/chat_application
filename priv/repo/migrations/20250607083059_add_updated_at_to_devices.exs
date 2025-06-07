defmodule WhatsappClone.Repo.Migrations.AddUpdatedAtToDevices do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :updated_at, :timestamptz, null: false, default: fragment("now()")
    end
  end
end
