# defmodule WhatsappClone.Contact do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "contacts" do
#     field :inserted_at, :utc_datetime_usec
#     field :user_id, :binary_id
#     field :contact_user_id, :binary_id

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(contact, attrs) do
#     contact
#     |> cast(attrs, [:inserted_at])
#     |> validate_required([:inserted_at])
#   end
# end
defmodule WhatsappClone.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :user_id, :binary_id
    field :contact_user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:user_id, :contact_user_id])
    |> validate_required([:user_id, :contact_user_id])
    |> unique_constraint([:user_id, :contact_user_id])
  end
end
