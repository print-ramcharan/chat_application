# defmodule WhatsappCloneWeb.AuthToken do
#   @salt "user socket salt"

#   def sign(user_id) do
#     Phoenix.Token.sign(WhatsappCloneWeb.Endpoint, @salt, user_id)
#   end

#   def verify(token) do
#     case Phoenix.Token.verify(WhatsappCloneWeb.Endpoint, @salt, token, max_age: 86400) do
#       {:ok, user_id} -> {:ok, user_id}
#       _ -> :error
#     end
#   end
# end

defmodule WhatsappCloneWeb.AuthToken do
  # @secret "KnnD7jyxnhg0En/Zs4+XMXUFAVacWMV1uI+8b3EjEZNyBpdbfz9te6Z9ymLlOYz"
   @secret Application.get_env(:whatsapp_clone, WhatsappCloneWeb.AuthToken)[:secret]
  def verify(token) do
    signer = Joken.Signer.create("HS256", @secret)

    case Joken.verify(token, signer) do
      {:ok, %{"sub" => user_id}} -> {:ok, user_id}
      _ -> :error
    end
  end
end
