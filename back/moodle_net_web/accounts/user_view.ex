defmodule MoodleNetWeb.Accounts.UserView do
  use MoodleNetWeb, :view
  alias MoodleNetWeb.OAuth.OAuthView

  def render("registration.json", %{token: token, user: user}) do
    %{
      user: render("user.json", %{user: user}),
      token: OAuthView.render("token.json", token: token)
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
