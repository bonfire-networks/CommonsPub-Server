defmodule MoodleNet.OAuth.Authorization do
  use Ecto.Schema

  alias MoodleNet.Accounts.User
  alias MoodleNet.Repo
  alias MoodleNet.OAuth.{Authorization, App}

  alias Ecto.Changeset

  schema "oauth_authorizations" do
    field(:hash, :string)
    field(:valid_until, :naive_datetime_usec)
    field(:used, :boolean, default: false)
    belongs_to(:user, MoodleNet.Accounts.User)
    belongs_to(:app, App)

    timestamps()
  end

  def build(user_id, app_id) do
    hash = MoodleNet.Token.random_key()

    %Authorization{}
    |> Changeset.change(
      hash: hash,
      used: false,
      user_id: user_id,
      app_id: app_id,
      valid_until: expiration_time()
    )
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.foreign_key_constraint(:app_id)
  end

  defp expiration_time(), do: NaiveDateTime.add(NaiveDateTime.utc_now(), 60 * 10)

  def use_changeset(%Authorization{used: true} = auth) do
    auth
    |> Changeset.change()
    |> Changeset.add_error(:used, "already used")
  end

  def use_changeset(%Authorization{} = auth) do
    if expired?(auth) do
      auth
      |> Changeset.change()
      |> Changeset.add_error(:valid_until, "expired")
    else
      Changeset.change(auth, used: true)
    end
  end

  def expired?(%Authorization{valid_until: valid_until}),
    do: NaiveDateTime.compare(valid_until, NaiveDateTime.utc_now()) == :gt
end
