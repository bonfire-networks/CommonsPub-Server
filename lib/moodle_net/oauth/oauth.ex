# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth do
  @moduledoc """
  The OAuth context.
  """

  alias MoodleNet.{Common, OAuth, Repo}
  alias MoodleNet.OAuth.{
    Authorization,
    AuthorizationAlreadyClaimedError,
    AuthorizationExpiredError,
    Token,
    TokenExpiredError,
    TokenNotFoundError,
    UserEmailNotConfirmedError,
    InvalidCredentialError,
  }
  alias MoodleNet.Users.User
  alias Ecto.{Changeset, UUID}

  @default_token_validity 60 * 10 # seconds: this seems short, but it's what alex set it to

  def fetch_auth(id), do: Repo.fetch(Authorization, id)
  def fetch_auth_by(params), do: Repo.fetch_by(Authorization, params)

  def fetch_session_token(%User{id: user_id}),
    do: Repo.fetch_by(Token, user_id: user_id)

  @doc """
  Fetches a token along with the user it is linked to.

  Note: does not validate the validity of the token, you must do that afterwards.
  """
  @spec fetch_token_and_user(token :: binary) :: {:ok, %Token{}} | {:error, TokenNotFoundError.t}
  def fetch_token_and_user(token) when is_binary(token) do
    case UUID.cast(token) do
      {:ok, token} -> Repo.single(fetch_token_and_user_query(token))
      :error -> {:error, TokenNotFoundError.new()}
    end
  end

  defp fetch_token_and_user_query(token) do
    import Ecto.Query, only: [from: 2]
    from t in Token,
      inner_join: a in assoc(t, :auth),
      inner_join: u in assoc(a, :user),
      where: t.id == ^token,
      select: {t, u}
  end

  @doc "Creates an authorization for a user"
  @spec create_auth(%User{}) :: {:ok, %Authorization{}} | {:error, UserEmailNotConfirmedError.t | Changeset.t}
  def create_auth(%User{confirmed_at: nil}=user),
    do: {:error, UserEmailNotConfirmedError.new(user)}

  def create_auth(%User{id: id}=user),
    do: Repo.insert(Authorization.create_changeset(id))

  @doc """
  Creates a token for a user, without requiring an Authorization

  Requires a correct password for the token to be created.
  """
  @spec create_token(User.t(), binary) :: {:ok, Authorization.t()} | {:error, atom | Changeset.t()}
  def create_token(%User{id: id} = user, password) do
    if Argon2.verify_pass(password, user.password_hash) do
      Repo.insert(Token.user_only_changeset(user))
    else
      {:error, InvalidCredentialError.new()}
    end
  end

  @doc "Turns an authorization into a token if it hasn't expired or been claimed"
  def claim_token(auth, now \\ DateTime.utc_now())
  def claim_token(%Authorization{}=auth, %DateTime{}=now) do
    Repo.transact_with fn ->
      with :ok <- ensure_valid(auth, now),
           {:ok, auth} <- Repo.update(Authorization.claim_changeset(auth)) do
        auth = Repo.preload(auth, :user)
        Repo.insert(Token.create_changeset(auth.user, auth))
      end
    end
  end

  def hard_delete(%Token{}=token), do: Common.hard_delete(token)
  def hard_delete(%Authorization{}=auth), do: Common.hard_delete(auth)

  @doc """
  Ensures validity:
  - that a User is valid to create an authority
  - that an Authority is valid to create a token

 Authorization or Token is valid.
  For both: ensures not expired
  For authorization ensures not already claimed
  """
  def ensure_valid(auth_or_token, now \\ DateTime.utc_now())

  def ensure_valid(%User{confirmed_at: nil}=user, %DateTime{}),
    do: {:error, UserEmailNotConfirmedError.new(user)}

  def ensure_valid(%User{}, %DateTime{}), do: :ok

  def ensure_valid(%Authorization{}=auth, %DateTime{}=now) do
    cond do
      :gt != DateTime.compare(auth.expires_at, now) ->
        {:error, AuthorizationExpiredError.new(auth)}
      not is_nil(auth.claimed_at) ->
        {:error, AuthorizationAlreadyClaimedError.new(auth)}
      true -> :ok
    end
  end

  def ensure_valid(%Token{}=token, %DateTime{}=now) do
    if :gt == DateTime.compare(token.expires_at, now),
      do: :ok,
      else: {:error, TokenExpiredError.new(token)}
  end

end
