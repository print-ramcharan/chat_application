defmodule WhatsappCloneWeb.UserView do
  use WhatsappCloneWeb, :view

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      avatar_url: user.avatar_url,
      phone_number: user.phone_number
    }
  end
end
