# defmodule WhatsappClone.User do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id
#   schema "users" do
#     field :public_key, :string
#     field :username, :string
#     field :phone_number, :string
#     field :display_name, :string
#     field :avatar_url, :string

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(user, attrs) do
#     user
#     |> cast(attrs, [:username, :phone_number, :display_name, :avatar_url, :public_key])
#     |> validate_required([:username, :phone_number, :display_name, :avatar_url, :public_key])
#     |> unique_constraint(:phone_number)
#     |> unique_constraint(:username)
#   end
# end

# defmodule WhatsappClone.User do
#   use Ecto.Schema
#   import Ecto.Changeset

#   @primary_key {:id, :binary_id, autogenerate: true}
#   @foreign_key_type :binary_id

#   schema "users" do
#     field :public_key, :string
#     field :username, :string
#     field :phone_number, :string
#     field :display_name, :string
#     field :avatar_url, :string

#     timestamps(type: :utc_datetime)
#   end

#   @doc false
#   def changeset(user, attrs) do
#     user
#     |> cast(attrs, [:username, :phone_number, :display_name, :avatar_url, :public_key])
#     |> validate_required([:username, :phone_number, :display_name, :public_key])
#     |> unique_constraint(:phone_number)
#     |> unique_constraint(:username)
#   end

# end

defmodule WhatsappClone.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @derive {Jason.Encoder, only: [:id, :display_name, :avatar_data, :username, :phone_number]}
  schema "users" do
    field :username, :string
    field :phone_number, :string
    field :display_name, :string
    field :avatar_data, :binary
    field :public_key, :string

    # for authentication:
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :fcm_token, :string


    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for user registration: hashes the password.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :phone_number, :display_name, :avatar_data, :public_key, :password])
    |> validate_required([:username, :phone_number, :display_name, :password])
    |> validate_length(:password, min: 6)
    |> unique_constraint(:phone_number)
    |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    if password = get_change(changeset, :password) do
      change(changeset, hashed_password: Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
