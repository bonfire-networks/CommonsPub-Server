defmodule MoodleNet.OAuth do
  @moduledoc """
  The OAuth context.
  """

  alias MoodleNet.Repo
  alias MoodleNet.Accounts.{NewUser}
  alias MoodleNet.OAuth.{App, Authorization, Token}
  alias Ecto.Multi

  def create_app(params) do
    App.register_changeset(params)
    |> Repo.insert()
  end

  @local_app_id "https://moodlenet/"
  def get_local_app() do
    # FIXME Momentary shortcut!
    if app = get_app_by(client_id: @local_app_id), do: app, else: create_local_app()
  end

  defp create_local_app() do
    %App{
      client_name: "MoodleNet",
      client_id: @local_app_id,
      redirect_uri: @local_app_id,
      website: @local_app_id,
      scopes: "read,write,follow"
    }
    |> Repo.insert!()
  end

  def get_app_by(params) do
    Repo.get_by(App, params)
  end

  def get_app_by!(params) do
    Repo.get_by!(App, params)
  end

  def get_auth_by(params) do
    Repo.get_by(Authorization, params)
  end

  def get_auth_by!(params) do
    Repo.get_by!(Authorization, params)
  end

  def get_user_by_token(token) do
    with {:ok, {user_id, _}} <- MoodleNet.Token.split_id_and_token(token) do
      user_id
      |> get_user_by_token_query(token)
      |> Repo.one()
      |> case do
        nil -> {:error, :token_not_found}
        user -> {:ok, user}
      end
    else
      _ -> {:error, :invalid_token}
    end
  end

  defp get_user_by_token_query(user_id, token) do
    import Ecto.Query, only: [from: 2]

    from(t in Token,
      # FIXME valid_until not used here?
      where: t.hash == ^token and t.user_id == ^user_id,
      inner_join: u in assoc(t, :user),
      select: u
    )
  end

  def create_token(user_id, app_id \\ nil) do
    app_id = app_id || get_local_app().id

    Token.build(app_id, user_id)
    |> Repo.insert()
  end

  def exchange_token(app, auth) do
    with true <- auth.app_id == app.id do
      Multi.new()
      |> Multi.update(:authorization, Authorization.use_changeset(auth))
      |> Multi.insert(:token, Token.build(app.id, auth.user_id))
      |> Repo.transaction()
    end
  end

  def create_authorization(user_id, app_id) do
    Authorization.build(user_id, app_id)
    |> Repo.insert()
  end

  def revoke_token(hash, app_id \\ nil) do
    app_id = app_id || get_local_app().id
    revoke_token_query(hash, app_id) |> Repo.delete_all()
  end

  defp revoke_token_query(hash, app_id) do
    import Ecto.Query, only: [from: 2]

    from(t in Token, where: t.hash == ^hash and t.app_id == ^app_id)
  end
end
