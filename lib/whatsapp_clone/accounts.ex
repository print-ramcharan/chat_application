# defmodule WhatsappClone.Accounts do
#   import Ecto.Query, warn: false
#   alias WhatsappClone.Repo
#   alias WhatsappClone.User

#   def create_user(attrs) do
#     %User{}
#     |> User.changeset(attrs)
#     |> Repo.insert()
#   end

#   def get_user_by_username(username) do
#     Repo.get_by(User, username: username)
#   end
# end
# defmodule WhatsappClone.Accounts do
#   @moduledoc """
#   The Accounts context: handles users and device registration logic.
#   """

#   import Ecto.Query, warn: false
#   alias WhatsappClone.{Repo, User, Device}
#   alias Bcrypt

#   ##
#   ## USER FUNCTIONS
#   ##

#   @doc """
#   Registers a new user. Expects params like:
#       %{
#         "username" => "...",
#         "phone_number" => "...",
#         "display_name" => "...",
#         "avatar_url" => "...",
#         "public_key" => "...",
#         "password"   => "plaintext"
#       }

#   Returns {:ok, %User{}} or {:error, changeset}.
#   """
#   def register_user(params) do
#     %User{}
#     |> User.registration_changeset(params)
#     |> Repo.insert()
#   end

#   @doc """
#   Authenticates a user by phone_number (or email) + password.
#   Returns {:ok, user, token} or {:error, :invalid_credentials}.
#   """
#   def authenticate_user(phone_number, password) do
#     case Repo.get_by(User, phone_number: phone_number) do
#       nil ->
#         Bcrypt.no_user_verify()
#         {:error, :invalid_credentials}

#       %User{} = user ->
#         if Bcrypt.check_pass(password, user.hashed_password) do
#           # Generate a simple token (JWT or Phoenix.Token). Here we use Phoenix.Token:
#           token = Phoenix.Token.sign(WhatsappCloneWeb.Endpoint, "user socket", user.id)

#           {:ok, user, token}
#         else
#           {:error, :invalid_credentials}
#         end
#     end
#   end
#   # In WhatsappClone.Accounts
# def authenticate_user(phone_number, password) do
#   case get_user_by_phone(phone_number) do
#     nil -> {:error, :invalid_credentials}
#     user ->
#       if valid_password?(user, password) do
#         {:ok, user}
#       else
#         {:error, :invalid_credentials}
#       end
#   end
# end


#   @doc """
#   Fetch a user by ID. Returns %User{} or nil.
#   """
#   def get_user(id), do: Repo.get(User, id)

#   @doc """
#   Search users by username or display_name containing `q`. Returns list of users.
#   """
#   def search_users(%{"query" => q}) do
#     like_pattern = "%#{q}%"

#     User
#     |> where([u], ilike(u.username, ^like_pattern) or ilike(u.display_name, ^like_pattern))
#     |> select([u], %{id: u.id, username: u.username, display_name: u.display_name, avatar_url: u.avatar_url})
#     |> Repo.all()
#   end

#   ##
#   ## DEVICE FUNCTIONS
#   ##

#   @doc """
#   Registers (or updates) a device for a given user_id.
#   Expects params like:
#       %{"device_token" => "...", "platform" => "ios" | "android"}
#   """
#   def create_device(user_id, attrs) do
#     attrs = Map.put(attrs, "user_id", user_id)

#     %Device{}
#     |> Device.changeset(attrs)
#     |> Repo.insert(on_conflict: :replace_all, conflict_target: [:id])
#   end

#   @doc """
#   Deletes a device by its ID, but only if it belongs to `user_id`.
#   Returns :ok or {:error, :not_found}.
#   """
#   def delete_device(user_id, device_id) do
#     case Repo.get(Device, device_id) do
#       %Device{user_id: ^user_id} = device ->
#         Repo.delete(device)
#         :ok

#       _ ->
#         {:error, :not_found}
#     end
#   end
# end


defmodule WhatsappClone.Accounts do
  @moduledoc """
  The Accounts context: handles users and device registration logic.
  """

  import Ecto.Query, warn: false
  alias WhatsappClone.{Repo, User, Device}
  alias Bcrypt

  ##
  ## USER FUNCTIONS
  ##

  @doc """
  Registers a new user. Expects params like:
      %{
        "username" => "...",
        "phone_number" => "...",
        "display_name" => "...",
        "avatar_url" => "...",
        "public_key" => "...",
        "password"   => "plaintext"
      }

  Returns {:ok, %User{}} or {:error, changeset}.
  """
  def register_user(params) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Authenticates a user by phone_number and password.
  Returns {:ok, user} or {:error, :invalid_credentials}.
  """
  def authenticate_user(phone_number, password) do
    case Repo.get_by(User, phone_number: phone_number) do
      nil ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      %User{} = user ->
        if Bcrypt.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  @doc """
  Fetch a user by ID.
  """
  def get_user(id), do: Repo.get(User, id)

  def update_user_fcm_token(user_id, fcm_token) do
    user = Repo.get!(WhatsappClone.User, user_id)
    changeset = Ecto.Changeset.change(user, %{fcm_token: fcm_token})
    Repo.update(changeset)
  end

  @doc """
  Search users by username or display_name containing `query`.
  """
  def search_users(%{"query" => q}) do
    like_pattern = "%#{q}%"

    User
    |> where([u], ilike(u.username, ^like_pattern) or ilike(u.display_name, ^like_pattern))
    |> select([u], %{
      id: u.id,
      username: u.username,
      display_name: u.display_name,
      avatar_url: u.avatar_data
    })
    |> Repo.all()
  end

  ##
  ## DEVICE FUNCTIONS
  ##

  @doc """
  Registers (or updates) a device for a given user_id.
  Expects:
      %{"device_token" => "...", "platform" => "ios" | "android"}
  """
  def create_device(attrs) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: [:id])
  end

  def get_user!(id), do: Repo.get!(User, id)


  # def update_avatar(user_id, avatar_url) do
  #   user = get_user!(user_id)

  #   user
  #   |> Ecto.Changeset.change(%{avatar_url: avatar_url})
  #   |> WhatsappClone.Repo.update()
  # end
  # def update_avatar(user_id, base64_image) do
  #   user = get_user!(user_id)

  #   user
  #   |> Ecto.Changeset.change(%{avatar_data: base64_image})
  #   |> Repo.update()
  # end

  # def update_avatar(user_id, base64_avatar) do
  #   with {:ok, user} <- get_user(user_id),
  #        {:ok, binary_data} <- Base.decode64(base64_avatar) do
  #     user
  #     |> Ecto.Changeset.change(avatar_data: binary_data)
  #     |> Repo.update()
  #   else
  #     _ -> {:error, :invalid_avatar_data}
  #   end
  # end
  def update_avatar(user_id, base64_avatar) do
    with %User{} = user <- get_user(user_id),
         {:ok, binary_data} <- Base.decode64(base64_avatar) do
      user
      |> Ecto.Changeset.change(avatar_data: binary_data)
      |> Repo.update()
    else
      nil -> {:error, :user_not_found}
      :error -> {:error, :invalid_avatar_data}
    end
  end

  # defp get_user(id), do: Repo.get(User, id)




  def delete_device(user_id, device_id) do
    case Repo.get(Device, device_id) do
      %Device{user_id: ^user_id} = device ->
        Repo.delete(device)
        :ok

      _ ->
        {:error, :not_found}
    end
  end
end
