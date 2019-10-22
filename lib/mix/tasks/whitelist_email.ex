# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Mix.Tasks.MoodleNet.WhitelistEmail do
  use Mix.Task
  import Mix.Ecto

  @usage "mix moodle_net.whitelist_email EMAIL"

  @shortdoc "Whitelist an address to allow login locally."
  @moduledoc """
  External developers do not typically have moodle email addresses and so need
  to whitelist their address when signing up on a local instance.

  Usage:

    $ #{@usage}
  """

  def run([email | _]) when is_binary(email) do
    Mix.Task.run("app.start")

    if MoodleNet.Accounts.is_email_in_whitelist?(email) do
      Mix.shell.info("#{email} already present in whitelist.")
    else
      {:ok, _} = MoodleNet.Accounts.add_email_to_whitelist(email)
      Mix.shell.info("#{email} added to whitelist.")
    end
  end

  def run(_args), do: Mix.shell.error("""
  Invalid parameters.

  Usage:

    #{@usage}
  """)
end
