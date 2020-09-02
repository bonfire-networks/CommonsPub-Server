# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Mail.MailService do
  @moduledoc """
  A service for sending email
  """
  use Bamboo.Mailer, otp_app: :commons_pub

  def maybe_deliver_later(mail) do
    Application.get_env(:commons_pub, __MODULE__, [])
    |> Keyword.get(:adapter)
    |> case do
      nil -> nil
      _other -> __MODULE__.deliver_later(mail)
    end
  end

  def maybe_deliver_now(mail) do
    Application.get_env(:commons_pub, __MODULE__, [])
    |> Keyword.get(:adapter)
    |> case do
      nil -> nil
      _other -> __MODULE__.deliver_now(mail)
    end
  end
end
