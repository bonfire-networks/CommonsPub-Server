# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Whitelist.EmailDomainWhitelist do
  @moduledoc "Whitelists email domains for registration"
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Whitelist.EmailDomainWhitelist

  @domain_regexp ~r/[a-z]+(?:\.[a-z]+)+/

  @primary_key false
  schema "mn_whitelist_email_domain" do
    field(:domain, :string, primary_key: true)
  end

  def changeset(domain) do
    Changeset.cast %EmailDomainWhitelist{}, %{domain: domain}
    Changeset.validate_format(:domain, @domain_regexp)
  end
  
end
