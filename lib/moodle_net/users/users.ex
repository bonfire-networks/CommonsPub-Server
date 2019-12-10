# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do
  @doc """
  A Context for dealing with Users.
  """
  import Ecto.Query, only: [from: 2]
  alias MoodleNet.{Access, Actors, Common, Feeds, Meta, Repo}
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Feedsk
  alias MoodleNet.Mail.{Email, MailService}

  alias MoodleNet.Users.{
    EmailConfirmToken,
    Inbox,
    LocalUser,
    Outbox,
    ResetPasswordToken,
    TokenAlreadyClaimedError,
    TokenExpiredError,
    User,
    UserFlag,
  }

  alias Ecto.Changeset

  @doc "Fetches a user by id"
  @spec fetch(id :: binary()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch(id) when is_binary(id) do
    with {:ok, user} <- Repo.single(fetch_q(id)) do
      {:ok, preload(user)}
    end
  end

  def fetch_q(id) do
    from(u in User,
      where: u.id == ^id,
      where: is_nil(u.deleted_at)
    )
  end

  @spec fetch_by_username(username :: binary()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_by_username(username) when is_binary(username) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.fetch_by_username(username),
           {:ok, user} <- Repo.fetch_by(User, actor_id: actor.id) do
        {:ok, preload_local_user(%User{user | actor: actor})}
      end
    end)
  end

  @spec fetch_any_by_username(username :: binary()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_any_by_username(username) when is_binary(username) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.fetch_any_by_username(username),
           {:ok, user} <- Repo.fetch_by(User, actor_id: actor.id) do
        {:ok, preload_actor(%User{user | actor: actor})}
      end
    end)
  end

  @spec fetch_by_email(email :: binary()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_by_email(email) when is_binary(email) do
    with {:ok, local_user} <- Repo.single(fetch_by_email_q(email)) do
      user = Repo.preload(local_user, :user).user
      user = preload_actor(%{user | local_user: local_user})
      {:ok, user}
    end
  end

  defp fetch_by_email_q(email) do
    from(lu in LocalUser,
      where: lu.email == ^email,
      where: is_nil(lu.deleted_at)
    )
  end

  @spec fetch_actor(User.t()) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_actor(%User{actor_id: id}), do: Actors.fetch(id)
  def fetch_actor(%User{actor: actor}), do: Actors.fetch(actor.id)

  def fetch_actor_private(%User{actor_id: id}), do: Actors.fetch_private(id)

  @spec fetch_local_user(User.t()) :: {:ok, LocalUser.t()} | {:error, NotFoundError.t()}
  def fetch_local_user(%User{local_user_id: id}) do
    Repo.fetch(LocalUser, id)
  end

  def fetch_local_user(%User{local_user: local_user} = user) do
    Repo.fetch(LocalUser, local_user.id)
  end

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
  @spec register(attrs :: map, opts :: Keyword.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def register(%{} = attrs, opts \\ []) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, local_user} <- insert_local_user(attrs),
           :ok <- check_register_access(local_user.email, opts),
           {:ok, inbox} <- Feeds.create_feed(),
           {:ok, outbox} <- Feeds.create_feed(),
           attrs2 = Map.merge(attrs, %{inbox_id: inbox.id, outbox_id: outbox.id}),
           {:ok, user} <- Repo.insert(User.local_register_changeset(actor, local_user, attrs2)),
           {:ok, token} <- create_email_confirm_token(local_user) do
        user
        |> Email.welcome(token)
        |> MailService.deliver_now()

        user = %{user | actor: actor, local_user: local_user, email_confirm_tokens: [token]}
        {:ok, user}
      end
    end)
  end

  @doc """
  Register a remote-only user. The user will not have a :local_user relation, only an actor
  will be created.
  """
  @spec register_remote(map, Keyword.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def register_remote(attrs, opts \\ []) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, outbox} <- Feeds.create_feed(),
           attrs2 = Map.put(attrs, :outbox_id, outbox.id),
           {:ok, user} <- Repo.insert(User.register_changeset(actor, attrs2)) do
        {:ok, %{user | actor: actor}}
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
      {:ok, %{local_user | password: nil}}
    end
  end

  defp create_email_confirm_token(%LocalUser{} = local_user),
    do: Repo.insert(EmailConfirmToken.create_changeset(local_user))

  @doc "Uses an email confirmation token, returns ok/error tuple"
  @spec claim_email_confirm_token(token :: any, DateTime.t()) ::
          {:ok, User.t()} | {:error, Changeset.t()}
  def claim_email_confirm_token(token, now \\ DateTime.utc_now())

  def claim_email_confirm_token(token, %DateTime{} = now) when is_binary(token) do
    Repo.transact_with(fn ->
      with {:ok, token} <- Repo.fetch(EmailConfirmToken, token),
           :ok <- validate_token(token, :confirmed_at, now),
           {:ok, _} <- Repo.update(EmailConfirmToken.claim_changeset(token)),
           {:ok, user} <- Repo.fetch_by(User, local_user_id: token.local_user_id) do
        confirm_email(user)
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
  @spec confirm_email(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def confirm_email(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, local_user} <- fetch_local_user(user),
           {:ok, local_user} <- Repo.update(LocalUser.confirm_email_changeset(local_user)) do
        user = preload_actor(%{ user | local_user: local_user})
        {:ok, user}
      end
    end)
  end

  @spec unconfirm_email(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def unconfirm_email(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, local_user} <- fetch_local_user(user),
           {:ok, local_user} <- Repo.update(LocalUser.unconfirm_email_changeset(local_user)) do
        user = preload_actor(%{ user | local_user: local_user })
        {:ok, user}

      end
    end)
  end

  @spec request_password_reset(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def request_password_reset(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, local_user} <- fetch_local_user(user),
           {:ok, token} <- Repo.insert(ResetPasswordToken.create_changeset(local_user)) do
        user
        |> Email.reset_password_request(token)
        |> MailService.deliver_now()

        {:ok, token}
      end
    end)
  end

  @spec claim_password_reset(token :: any, binary(), DateTime.t()) ::
          {:ok, User.t()} | {:error, Changeset.t()}
  def claim_password_reset(token, password, now \\ DateTime.utc_now())

  def claim_password_reset(token, password, %DateTime{} = now)
      when is_binary(password) do
    Repo.transact_with(fn ->
      with {:ok, token} <- Repo.fetch(ResetPasswordToken, token),
           :ok <- validate_token(token, :reset_at, now),
           {:ok, local_user} <- Repo.fetch(LocalUser, token.local_user_id),
           {:ok, user} <- Repo.fetch_by(User, local_user_id: local_user.id),
           {:ok, token} <- Repo.update(ResetPasswordToken.claim_changeset(token)),
           {:ok, _} <- Repo.update(LocalUser.update_changeset(local_user, %{password: password})) do
        user
        |> Email.password_reset()
        |> MailService.deliver_now()

	user = preload_actor(%{ user | local_user: local_user })
	{:ok, user}
      end
    end)
  end

  defp validate_token(token, claim_field, now) do
    cond do
      not is_nil(Map.fetch!(token, claim_field)) ->
        {:error, TokenAlreadyClaimedError.new()}

      :gt == DateTime.compare(now, token.expires_at) ->
        {:error, TokenExpiredError.new()}

      true ->
        :ok
    end
  end

  @spec update(User.t(), map) :: {:ok, User.t()} | {:error, Changeset.t()}
  def update(%User{} = user, attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- fetch_actor(user),
           {:ok, local_user} <- fetch_local_user(user),
           {:ok, user} <- Repo.update(User.update_changeset(user, attrs)),
           {:ok, actor} <- Actors.update(actor, attrs),
           {:ok, local_user} <- Repo.update(LocalUser.update_changeset(local_user, attrs)) do
        user = %{ user | local_user: local_user, actor: actor }
        {:ok, user}
      end
    end)
  end

  @spec update_remote(User.t(), map) :: {:ok, User.t()} | {:error, Changeset.t()}
  def update_remote(%User{} = user, attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- fetch_actor(user),
           {:ok, user} <- Repo.update(User.update_changeset(user, attrs)),
           {:ok, actor} <- Actors.update(actor, attrs) do
        user = %{ user | actor: actor }
        {:ok, user}
      end
    end)
  end

  @spec soft_delete(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def soft_delete(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, user} <- Repo.update(User.soft_delete_changeset(user)),
           {:ok, local_user} <- fetch_local_user(user),
           {:ok, local_user} <- Repo.update(LocalUser.soft_delete_changeset(local_user)) do
        user = preload_actor(%{ user | local_user: local_user})
        {:ok, user}
      end
    end)
  end

  @spec soft_delete_remote(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def soft_delete_remote(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, user} <- Repo.update(User.soft_delete_changeset(user)) do
        user = preload_actor(user)
        {:ok, user}
      end
    end)
  end

  @spec make_instance_admin(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def make_instance_admin(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, local_user} <- fetch_local_user(user),
           {:ok, local_user} <- Repo.update(LocalUser.make_instance_admin_changeset(local_user)) do
        user = preload_actor(%{ user | local_user: local_user})
        {:ok, user}
      end
    end)
  end

  @spec unmake_instance_admin(User.t()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def unmake_instance_admin(%User{} = user) do
    Repo.transact_with(fn ->
      with {:ok, local_user} <- fetch_local_user(user),
           {:ok, local_user} <- Repo.update(LocalUser.unmake_instance_admin_changeset(local_user)) do
        user = preload_actor(%{ user | local_user: local_user})
        {:ok, user}
      end
    end)
  end

  def inbox(%User{inbox_id: inbox_id}=user, opts \\ %{}) do
    Repo.transaction(fn ->
      subs = [user.inbox_id | Feeds.active_subs_for(user)]
      Feeds.feed_activities(subs)
    end)
  end

  def outbox(%User{}=user, opts \\ %{}) do
    Feeds.feed_activities([user.outbox_id], opts)
  end

  @spec preload(User.t(), Keyword.t()) :: User.t()
  def preload(user, opts \\ [])

  def preload(%User{} = user, opts) do
    Repo.preload(user, [:local_user, :actor], opts)
  end

  @spec preload_actor(User.t(), Keyword.t()) :: User.t()
  def preload_actor(%User{} = user, opts \\ []) do
    Repo.preload(user, :actor, opts)
  end

  @spec preload_local_user(User.t(), Keyword.t()) :: User.t()
  def preload_local_user(%User{} = user, opts \\ []) do
    Repo.preload(user, :local_user, opts)
  end
end
