# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Whitelist.RegisterEmailDomainWhitelist do
  @moduledoc """
  A simple standalone schema listing domains for which emails at those
  domains are permitted to register a MoodleNet account while public
  signup is disabled.
  """
  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Whitelist.RegisterEmailDomainWhitelist

  @domain_regexp ~r/[a-z]+(?:\.[a-z]+)+/

  standalone_schema "mn_whitelist_register_email_domain" do
    field(:domain, :string)
    timestamps()
  end

  @cast ~w(domain)a
  @required @cast
  
  @doc "A changeset for both creation and update purposes"
  def changeset(entry \\ %RegisterEmailDomainWhitelist{}, fields)
  def changeset(%RegisterEmailDomainWhitelist{}=entry, fields) do
    entry
    |> Changeset.cast(fields, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_format(:domain, @domain_regexp)
    |> Changeset.unique_constraint(:domain)
  end
  
end
