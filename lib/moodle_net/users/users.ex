# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do
  @doc """
  A "Context" for dealing with users, both local and remote
  """
  alias MoodleNet.{Actors, Common, Meta, Repo, Whitelists}
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Users.{
    EmailConfirmToken,
    TokenAlreadyClaimedError,
    TokenExpiredError,
    User,
    UserFlag,
  }
  alias Ecto.Changeset

  @doc "Fetches a user by id"
  @spec fetch(id :: binary) :: {:ok, %User{}} | {:error, NotFoundError.t}
  def fetch(id) when is_binary(id), do: Repo.fetch(User, id)

  @doc """
  Registers a user:
  1. Splits attrs into actor and user fields
  2. Inserts user (because the whitelist check isn't very good at crap emails yet
  3. Checks the whitelist
  4. Creates actor, email confirm token
  """
  # @spec register(attrs :: map) :: {:ok, %User{}} | {:error, Changeset.t}
  # @spec register(attrs :: map, opts :: Keyword.t) :: {:ok, %User{}} | {:error, Changeset.t}
  def register(%{} = attrs, opts \\ []) do
    Repo.transact_with(fn ->
      with {:ok, user} <- insert_user(attrs),
           :ok <- check_register_whitelist(attrs.email, opts),
           {:ok, actor} <- Actors.create_with_alias(user.id, attrs),
           {:ok, token} <- create_email_confirm_token(user) do
        user = %{ user | email_confirm_tokens: [token], password: nil }
        {:ok, %{ actor | alias: Meta.forge!(user) } }
      end
    end)
  end

  defp should_check_register_whitelist?(opts) do
    opts = opts ++ Application.get_env(:moodle_net, __MODULE__, [])
    not Keyword.get(opts, :public_registration, false)
  end

  defp check_register_whitelist(email, opts) do
    if should_check_register_whitelist?(opts),
      do: Whitelists.check_register_whitelist(email),
      else: :ok
  end

  defp insert_user(%{} = attrs) do
    Meta.point_to!(User)
    |> User.register_changeset(attrs)
    |> Repo.insert()
  end

  defp create_email_confirm_token(%User{} = user),
    do: Repo.insert(EmailConfirmToken.create_changeset(user))

  @doc "Uses an email confirmation token, returns ok/error tuple"
  def claim_email_confirm_token(token, now \\ DateTime.utc_now())
  def claim_email_confirm_token(token, %DateTime{} = now) when is_binary(token) do
    Repo.transact_with fn ->
      with {:ok, token} <- Repo.fetch(EmailConfirmToken, token),
           :ok <- validate_confirm_email_token(token, now),
           token = Repo.preload(token, :user),
           {:ok, _} <- Repo.update(EmailConfirmToken.claim_changeset(token)) do
        confirm_email(token.user)
      end
    end
  end

  defp validate_confirm_email_token(%EmailConfirmToken{} = token, %DateTime{} = now) do
    cond do
      not is_nil(token.confirmed_at) ->
	{:error, TokenAlreadyClaimedError.new(token)}

      :gt == DateTime.compare(now, token.expires_at) ->
	{:error, TokenExpiredError.new(token)}

      true -> :ok
    end
  end
							     


  @scope :test # use the email confirmation mechanism
  @doc """
  Verify a user's email address, allowing them to access their account.

  Note: this is for the benefit of the test suite. In normal use you
  should use the email confirmation mechanism.
  """
  def confirm_email(%User{} = user),
    do: Repo.update(User.confirm_email_changeset(user))

  def unconfirm_email(%User{} = user),
    do: Repo.update(User.unconfirm_email_changeset(user))

  ## TODO
  def update() do
  end

  @doc """
  Flags a user with a given reason
  {:ok, UserFlag} | {:error, reason}
  """
  def flag(actor, user, attrs = %{reason: _}),
    do: Common.flag(UserFlag, :flag_user?, actor, user, attrs)

  @doc """
  Undoes a previous flag
  {:ok, UserFlag} | {:error, term()}
  """
  def undo_flag(actor, user), do: Common.undo_flag(UserFlag, actor, user)

  @doc """
  Lists all UserFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(UserFlag, :list_user_flags?, actor, filters)

  def communities_query(%User{id: them_id} = them, %User{} = me) do
    Communities.Members.list()
    |> Communities.Members.filter_query(them_id)
  end

  def preload_actor(%User{} = user, opts),
    do: Repo.preload(user, :actor, opts)

  defp extra_relation(%User{id: id}) when is_integer(id), do: :user

  defp preload_extra(%User{} = user, opts \\ []),
    do: Repo.preload(user, extra_relation(user), opts)
end
