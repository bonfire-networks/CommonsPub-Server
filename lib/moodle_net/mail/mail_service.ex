# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Mail.MailService do
  @moduledoc """
  A service for sending email
  """
  use Bamboo.Mailer, otp_app: :moodle_net

  def maybe_deliver_later(mail) do
    Application.get_env(:moodle_net, __MODULE__, [])
    |> Keyword.get(:adapter)
    |> case do
         nil -> nil
         other -> __MODULE__.deliver_later(mail)
       end
  end

  def maybe_deliver_now(mail) do
    Application.get_env(:moodle_net, __MODULE__, [])
    |> Keyword.get(:adapter)
    |> case do
         nil -> nil
         other -> __MODULE__.deliver_now(mail)
       end
  end

end
