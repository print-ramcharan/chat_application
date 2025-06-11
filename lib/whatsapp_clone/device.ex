# defmodule WhatsappClone.Device do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "devices" do
#     field :public_key, :string
#     field :device_name, :string
#     field :inserted_at, :utc_datetime_usec
#     field :user_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(device, attrs) do
#     device
#     |> cast(attrs, [:device_name, :public_key, :inserted_at])
#     |> validate_required([:device_name, :public_key, :inserted_at])
#   end
# end
# defmodule WhatsappClone.Device do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "devices" do
#     field :public_key, :string
#     field :device_name, :string
#     belongs_to :user, WhatsappClone.User, type: :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(device, attrs) do
#     device
#     |> cast(attrs, [:device_name, :public_key, :user_id])
#     |> validate_required([:device_name, :public_key, :user_id])
#   end
# end

# defmodule WhatsappClone.Device do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "devices" do
#     field :device_token, :string
#     field :platform, :string
#     field :user_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(device, attrs) do
#     device
#     |> cast(attrs, [:device_token, :platform, :user_id])
#     |> validate_required([:device_token, :platform, :user_id])
#     |> unique_constraint(:device_token)
#   end
# end

defmodule WhatsappClone.Device do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "devices" do
    field :device_token, :string
    field :platform, :string
    field :device_name, :string
    field :public_key, :string

    belongs_to :user, WhatsappClone.User, type: :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(device, attrs) do
    device
    |> cast(attrs, [:device_token, :platform, :device_name, :public_key, :user_id])
    |> validate_required([:device_token, :platform, :device_name, :public_key, :user_id])
  end
end
