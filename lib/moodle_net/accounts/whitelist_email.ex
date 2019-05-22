defmodule MoodleNet.Accounts.WhitelistEmail do
  @moduledoc """
  Model to store the emails allowed to sign up
  """
  use Ecto.Schema

  @primary_key false
  schema "accounts_whitelist_emails" do
    field(:email, :string, primary_key: true)
  end
end
