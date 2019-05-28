defmodule MoodleNet.Email do
  import MoodleNetWeb.Gettext
  use Bamboo.Phoenix, view: MoodleNetWeb.EmailView

  def welcome(user, token) do
    url = email_confirmation_url(token)
    base_email(user)
    |> subject(gettext("Welcome to MoodleNet"))
    |> render(:welcome, user: user, url: url)
  end

  def reset_password_request(user, token) do
    url = reset_password_url(token)
    actor = ActivityPub.get_by_local_id(user.actor_id)
    base_email(user)
    |> subject(gettext("Did you forget your MoodleNet password?"))
    |> render(:reset_password_request, actor: actor, url: url)
  end

  def password_reset(user) do
    actor = ActivityPub.get_by_local_id(user.actor_id)
    base_email(user)
    |> subject(gettext("Your MoodleNet password has been reset"))
    |> render(:password_reset, actor: actor)
  end

  defp base_email(user) do
    new_email()
    |> to(user.email)
    # FIXME domain configuration
    |> from("no-reply@moodle.net")
    |> put_layout({MoodleNetWeb.LayoutView, :email})
  end

  defp email_confirmation_url(token) do
    MoodleNetWeb.Endpoint.struct_url()
    |> Map.put(:path, "/email_confirmation?token=#{token}")
    |> URI.to_string()
  end

  defp reset_password_url(token) do
    MoodleNetWeb.Endpoint.struct_url()
    |> Map.put(:path, "/reset_password?token=#{token}")
    |> URI.to_string()
  end
end