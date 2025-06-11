defmodule WhatsappCloneWeb.UserView do
  use WhatsappCloneWeb, :view

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      display_name: user.display_name,
      avatar_url: Base.encode64(user.avatar_data || <<>>),
      phone_number: user.phone_number
    }
  end
  def render("member.json", %{user: member}) do
    %{
      id: member.user.id,
      username: member.user.username,
      avatar_url: Base.encode64(member.user.avatar_data || <<>>),
      is_admin: member.is_admin
    }
  end



end
