# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Mail.Email do
  @moduledoc """
  Email Bamboo module
  """
  import CommonsPub.Web.Gettext
  alias CommonsPub.Users.User
  use Bamboo.Phoenix, view: CommonsPub.Web.EmailView

  def welcome(user, token) do
    url = email_confirmation_url(user.id, token.id)

    base_email(user)
    |> subject(gettext("Welcome to %{app_name}", app_name: app_name()))
    |> render(:welcome, user: user, url: url)
  end

  def reset_password_request(user, token) do
    url = reset_password_url(token.id)

    base_email(user)
    |> subject(gettext("Did you forget your %{app_name} password?", app_name: app_name()))
    |> render(:reset_password_request, user: user, url: url)
  end

  def password_reset(user) do
    base_email(user)
    |> subject(gettext("Your %{app_name} password has been reset", app_name: app_name()))
    |> render(:password_reset)
  end

  def invite(email) do
    url = invite_url(email)

    base_email(email)
    |> subject(gettext("You have been invited to join %{app_name}!", app_name: app_name()))
    |> render(:invite, url: url)
  end

  defp base_email(%User{local_user: %{email: email}}), do: base_email(email)

  defp base_email(email) when is_binary(email) do
    new_email()
    |> to(email)
    |> from("#{app_name()} <#{reply_to_email()}>")
    |> put_layout({CommonsPub.Web.LayoutView, :email})
  end

  defp email_confirmation_url(_id, token),
    do: frontend_url("confirm-email/#{token}")

  defp app_name(), do: Application.get_env(:commons_pub, :app_name)

  defp reset_password_url(token), do: frontend_url("~/password/change/#{token}")

  defp invite_url(email), do: frontend_url("~/signup?email=#{email}")

  # Note that the base url is expected to end without a slash (/)
  defp frontend_url(path), do: "#{frontend_base_url()}/#{path}"

  defp frontend_base_url(), do: Application.fetch_env!(:commons_pub, :frontend_base_url)

  defp reply_to_email do
    Application.fetch_env!(:commons_pub, CommonsPub.Mail.MailService)
    |> Keyword.get(:reply_to, "no-reply@moodle.net")
  end
end
