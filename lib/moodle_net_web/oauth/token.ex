defmodule MoodleNetWeb.OAuth.Token do
  use Ecto.Schema

  alias MoodleNet.Accounts.User
  alias MoodleNet.Repo
  alias MoodleNetWeb.OAuth.{Token, App, Authorization}

  schema "oauth_tokens" do
    field(:token, :string)
    field(:refresh_token, :string)
    field(:valid_until, :naive_datetime_usec)
    belongs_to(:user, MoodleNet.Accounts.User)
    belongs_to(:app, App)

    timestamps()
  end

  def exchange_token(app, auth) do
    with {:ok, auth} <- Authorization.use_token(auth),
         true <- auth.app_id == app.id do
      create_token(app, Repo.get(User, auth.user_id))
    end
  end

  def create_token(%App{} = app, %User{} = user) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64()
    refresh_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64()

    token = %Token{
      token: token,
      refresh_token: refresh_token,
      user_id: user.id,
      app_id: app.id,
      valid_until: NaiveDateTime.add(NaiveDateTime.utc_now(), 60 * 10)
    }

    Repo.insert(token)
  end
end
