# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth do
  @moduledoc """
  The OAuth context.
  """

  alias MoodleNet.Repo
  alias MoodleNet.OAuth.{
    Authorization,
    AuthorizationAlreadyClaimedError,
    AuthorizationExpiredError,
    Token,
    TokenExpiredError,
    TokenNotFoundError,
    UserEmailNotConfirmedError,
  }
  alias MoodleNet.Users.User
  alias Ecto.UUID

  @default_token_validity 60 * 10 # seconds: this seems short, but it's what alex set it to

  def fetch_auth_by(params), do: Repo.fetch_by(Authorization, params)

  @doc """
  Fetches a token along with the user it is linked to

  Note: does not validate the validity of the token, you must do that afterwards
  """
  def fetch_token_and_user(token) do
    case UUID.cast(token) do
      {:ok, token} -> Repo.een(fetch_token_and_user_query(token))
      :error -> {:error, TokenNotFoundError.new()}
    end
  end

  defp fetch_token_and_user_query(token) do
    import Ecto.Query, only: [from: 2]
    tok = UUID.cast(token)
    from t in Token,
      inner_join: a in assoc(t, :auth),
      inner_join: u in assoc(a, :user),
      where: t.id == ^token,
      select: {t, u}
  end

  def create_auth(%User{id: id}), do: Repo.insert(Authorization.create_changeset(id))

  @doc "Turns an authorization into a token if it hasn't expired or been claimed"
  def claim_token(auth, now \\ DateTime.utc_now()) do
    Repo.transact_with fn ->
      with :ok <- ensure_valid(auth, now),
           {:ok, auth} <- Repo.update(Authorization.claim_changeset(auth)) do
        Repo.insert(Token.create_changeset(auth.user_id, auth.id))
      end
    end
  end

  def hard_delete_token(token), do: Common.hard_delete(token)

  @doc """
  Ensures that an Authorization or Token is valid.
  For both: ensures not expired
  For authorization ensures not already claimed
  """
  def ensure_valid(auth_or_token, now \\ DateTime.utc_now())
  def ensure_valid(%Authorization{}=auth, now) do
    cond do
      :gt != DateTime.compare(auth.expires_at, now) ->
        {:error, AuthorizationExpiredError.new(auth)}
      not is_nil(auth.claimed_at) ->
        {:error, AuthorizationAlreadyClaimedError.new(auth)}
      true -> :ok
    end
  end
  def ensure_valid(%Token{}=token, now) do
    if :gt == DateTime.compare(token.expires_at, now),
      do: :ok,
      else: {:error, TokenExpiredError.new(token)}
  end

end
