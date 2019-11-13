# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do
  @doc """
  A Context for dealing with Users.
  """
  import Ecto.Query, only: [from: 2]
  alias MoodleNet.{Access, Actors, Common, Meta, Repo}
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Common.NotFoundError

  alias MoodleNet.Mail.{Email, MailService}

  alias MoodleNet.Users.{
    EmailConfirmToken,
    LocalUser,
    ResetPasswordToken,
    TokenAlreadyClaimedError,
    TokenExpiredError,
    User,
    UserFlag
  }

  alias Ecto.Changeset

  @doc "Fetches a user by id"
  @spec fetch(id :: binary) :: {:ok, %User{}} | {:error, NotFoundError.t()}
  def fetch(id) when is_binary(id), do: Repo.single(fetch_q(id))

  def fetch_q(id) do
    from(u in User,
      where: u.id == ^id,
      where: is_nil(u.deleted_at)
    )
  end

  # TODO: one query
  def fetch_by_username(username) when is_binary(username) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.fetch_by_username(username),
           {:ok, user} <- Meta.follow(Meta.forge!(User, actor.alias_id)) do
        {:ok, %User{user | actor: actor}}
      end
    end)
  end

  def fetch_by_email(email) when is_binary(email) do
    with {:ok, local_user} <- Repo.single(fetch_by_email_q(email)) do
      {:ok, %User{local_user: local_user}}
    end
  end

  defp fetch_by_email_q(email) do
    from(lu in LocalUser,
      where: lu.email == ^email,
      where: is_nil(lu.deleted_at)
    )
  end

  def fetch_actor(%User{actor_id: id}), do: Actors.fetch(id)
  def fetch_actor(%User{actor: actor}), do: {:ok, actor}

  def fetch_actor_private(%User{actor_id: id}), do: Actors.fetch_private(id)

  @doc """
  Registers a user:
  1. Splits attrs into actor and user fields
  2. Inserts user (because the access check isn't very good at crap emails yet)
  3. Checks the access
  4. Creates actor, email confirm token

  This is all controlled by options. An optional keyword list
  provided to this argument will be prepended to the application
  config under the path`[:moodle_net, MoodleNet.Users]`. Keys:

  `:public_registration` - boolean, default false. if false, accesss will be checked
  """
  # @spec register(attrs :: map) :: {:ok, %User{}} | {:error, Changeset.t}
  # @spec register(attrs :: map, opts :: Keyword.t) :: {:ok, %User{}} | {:error, Changeset.t}
  def register(%{} = attrs, opts \\ []) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, local_user} <- insert_local_user(attrs),
           :ok <- check_register_access(local_user.email, opts),
           {:ok, user} <- insert_user(actor, local_user, attrs),
           {:ok, token} <- create_email_confirm_token(local_user) do
        user
        |> Email.welcome(token)
        |> MailService.deliver_now()

        {:ok, %{user | email_confirm_tokens: [token], actor: actor, local_user: local_user}}
      end
    end)
  end

  defp should_check_register_access?(opts) do
    opts = opts ++ Application.get_env(:moodle_net, __MODULE__, [])
    not Keyword.get(opts, :public_registration, false)
  end

  defp check_register_access(email, opts) do
    if should_check_register_access?(opts),
      do: Access.check_register_access(email),
      else: :ok
  end

  defp insert_local_user(attrs) do
    with {:ok, local_user} <- Repo.insert(LocalUser.register_changeset(attrs)) do
      {:ok, %LocalUser{local_user | password: nil}}
    end
  end

  defp insert_user(actor, local_user, %{} = attrs) do
    Meta.point_to!(User)
    |> User.local_register_changeset(actor, local_user, attrs)
    |> Repo.insert()
  end

  defp create_email_confirm_token(%LocalUser{} = local_user),
    do: Repo.insert(EmailConfirmToken.create_changeset(local_user))

  @doc "Uses an email confirmation token, returns ok/error tuple"
  def claim_email_confirm_token(token, now \\ DateTime.utc_now())

  def claim_email_confirm_token(token, %DateTime{} = now) when is_binary(token) do
    Repo.transact_with(fn ->
      with {:ok, token} <- Repo.fetch(EmailConfirmToken, token),
           :ok <- validate_token(token, :confirmed_at, now),
           token = Repo.preload(token, :local_user),
           {:ok, _} <- Repo.update(EmailConfirmToken.claim_changeset(token)) do
        confirm_email(token.local_user)
      end
    end)
  end

  # use the email confirmation mechanism
  @scope :test
  @doc """
  Verify a user's email address, allowing them to access their account.

  Note: this is for the benefit of the test suite. In normal use you
  should use the email confirmation mechanism.
  """
  def confirm_email(%LocalUser{} = local_user),
    do: Repo.update(LocalUser.confirm_email_changeset(local_user))

  def unconfirm_email(%LocalUser{} = local_user),
    do: Repo.update(LocalUser.unconfirm_email_changeset(local_user))

  def request_password_reset(%LocalUser{} = local_user) do
    Repo.transact_with(fn ->
      with {:ok, token} <- Repo.insert(ResetPasswordToken.create_changeset(local_user)) do
        %{user: user} = preload(local_user)

        user
        |> Email.reset_password_request(token)
        |> MailService.deliver_now()

        {:ok, token}
      end
    end)
  end

  def claim_password_reset(token, password, now \\ DateTime.utc_now())

  def claim_password_reset(token, password, %DateTime{} = now)
      when is_binary(password) do
    Repo.transact_with(fn ->
      with {:ok, token} <- Repo.fetch(ResetPasswordToken, token),
           :ok <- validate_token(token, :reset_at, now),
           {:ok, local_user} <- Repo.fetch(LocalUser, token.local_user_id),
           {:ok, user} <- Repo.fetch_by(User, local_user_id: local_user.id),
           {:ok, token} <- Repo.update(ResetPasswordToken.claim_changeset(token)),
           {:ok, _} <- update(local_user, %{password: password}) do
        user
        |> Email.password_reset()
        |> MailService.deliver_now()

        {:ok, token}
      end
    end)
  end

  defp validate_token(token, claim_field, now) do
    cond do
      not is_nil(Map.fetch!(token, claim_field)) ->
        {:error, TokenAlreadyClaimedError.new(token)}

      :gt == DateTime.compare(now, token.expires_at) ->
        {:error, TokenExpiredError.new(token)}

      true ->
        :ok
    end
  end

  def update(%User{} = user, attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- fetch_actor(user),
           {:ok, user} <- Repo.update(User.update_changeset(user, attrs)),
           {:ok, actor} <- Actors.update(actor, attrs) do
        {:ok, %User{user | actor: actor}}
      end
    end)
  end

  def soft_delete(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, user} <- Repo.update(User.soft_delete_changeset(user)),
           {:ok, actor} <- fetch_actor(user),
           {:ok, actor} <- Actors.soft_delete(actor) do
        {:ok, %User{user | actor: actor}}
      end
    end)
  end

  def make_instance_admin(%User{} = user) do
    Repo.update(User.make_instance_admin_changeset(user))
  end

  def unmake_instance_admin(%User{} = user) do
    Repo.update(User.unmake_instance_admin_changeset(user))
  end

  def preload(user, opts \\ [])
  def preload(%User{} = user, opts),
    do: Repo.preload(user, [:local_user, :actor], opts)

  def preload(%LocalUser{} = local_user, opts),
    do: Repo.preload(local_user, [:user])

  def preload_actor(%User{} = user, opts),
    do: Repo.preload(user, :actor, opts)
end
