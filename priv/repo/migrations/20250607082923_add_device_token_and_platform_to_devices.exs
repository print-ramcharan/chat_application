defmodule WhatsappClone.Repo.Migrations.AddDeviceTokenAndPlatformToDevices do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :device_token, :string, null: false
      add :platform, :string, null: false
    end
  end
end
