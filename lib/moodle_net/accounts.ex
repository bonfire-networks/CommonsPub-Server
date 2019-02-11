defmodule MoodleNet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  # import Ecto.Query, warn: false
  alias MoodleNet.Repo
  alias Ecto.Multi

  alias MoodleNet.Accounts.{
    User,
    PasswordAuth,
    ResetPasswordToken,
    EmailConfirmationToken,
    WhitelistEmail
  }

  alias MoodleNet.{Mailer, Email}

  alias ActivityPub.SQL.Query

  @doc """
  Creates a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs \\ %{}) do
    # FIXME this should be a only one transaction
    actor_attrs =
      attrs
      |> Map.put("type", "Person")
      |> Map.delete(:password)
      |> Map.delete("password")
      |> set_default_icon()

    password = attrs[:password] || attrs["password"]

    Multi.new()
    |> Multi.run(:new_actor, fn _, _ -> ActivityPub.new(actor_attrs) end)
    |> Multi.run(:actor, fn repo, %{new_actor: new_actor} ->
      ActivityPub.insert(new_actor, repo)
    end)
    |> Multi.run(:user, fn repo, %{actor: actor} ->
      User.changeset(actor, attrs)
      |> repo.insert()
    end)
    |> Multi.run(
      :password_auth,
      &(PasswordAuth.create_changeset(&2.user.id, password) |> &1.insert())
    )
    |> Multi.run(
      :email_confirmation_token,
      &(EmailConfirmationToken.build_changeset(&2.user.id) |> &1.insert())
    )
    |> Multi.run(:email, fn _, %{user: user, email_confirmation_token: token} ->
      email =
        Email.welcome(user, token.token)
        |> Mailer.deliver_later()

      {:ok, email}
    end)
    |> Repo.transaction()
  end

  def update_user(actor, changes) do
    {icon_url, changes} = Map.pop(changes, :icon)
    {location_content, changes} = Map.pop(changes, :location)
    icon = Query.new() |> Query.belongs_to(:icon, actor) |> Query.one()
    location = Query.new() |> Query.belongs_to(:location, actor) |> Query.one()

    # FIXME this should be a transaction
    with {:ok, _icon} <- ActivityPub.update(icon, url: icon_url),
         {:ok, _location} <- ActivityPub.update(location, content: location_content),
         {:ok, actor} <- ActivityPub.update(actor, changes) do
      # FIXME
      actor =
        ActivityPub.reload(actor)
        |> Query.preload_assoc([:icon, :location])

      {:ok, actor}
    end
  end

  def delete_user(actor) do
    # FIXME this should be a transaction
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:attributed_to, actor)
    |> Query.delete_all()

    ActivityPub.delete(actor, [:icon, :location])
    :ok
  end

  def authenticate_by_email_and_pass(email, given_pass) do
    email
    |> user_and_password_auth_query()
    |> Repo.one()
    |> case do
      nil ->
        Comeonin.Pbkdf2.dummy_checkpw()
        {:error, :not_found}

      {user, password_auth} ->
        if Comeonin.Pbkdf2.checkpw(given_pass, password_auth.password_hash),
          do: {:ok, user},
          else: {:error, :unauthorized}
    end
  end

  defp user_and_password_auth_query(email) do
    import Ecto.Query

    from(u in User,
      where: u.email == ^email,
      inner_join: p in PasswordAuth,
      on: p.user_id == u.id,
      select: {u, p}
    )
  end

  def reset_password_request(email) do
    with user when not is_nil(user) <- Repo.get_by(User, email: email) do
      {:ok, reset_password_token} = renew_reset_password_token(user)

      Email.reset_password_request(user, reset_password_token.token)
      |> Mailer.deliver_later()

      {:ok, reset_password_token}
    else
      nil -> {:error, {:not_found, email, "User"}}
    end
  end

  defp renew_reset_password_token(user) do
    changeset = MoodleNet.Accounts.ResetPasswordToken.build_changeset(user)
    opts = [returning: true, on_conflict: :replace_all, conflict_target: :user_id]
    Repo.insert(changeset, opts)
  end

  def reset_password(token, new_password) do
    with {:ok, reset_password_token} <- get_reset_password_token(token) do
      password_ch = PasswordAuth.create_changeset(reset_password_token.user_id, new_password)

      opts = [
        returning: true,
        on_conflict: {:replace, [:password_hash, :updated_at]},
        conflict_target: :user_id
      ]

      Multi.new()
      |> Multi.delete(:reset_password_token, reset_password_token)
      |> Multi.insert(:password_hash, password_ch, opts)
      |> Multi.run(:email, fn repo, _ ->
        User
        |> repo.get(reset_password_token.user_id)
        |> Email.password_reset()
        |> Mailer.deliver_later()

        {:ok, nil}
      end)
      |> Repo.transaction()
    end
  end

  defp get_reset_password_token(full_token) do
    with {:ok, {user_id, _}} <- MoodleNet.Token.split_id_and_token(full_token),
         ret = %{token: rp_token} <- Repo.get_by(ResetPasswordToken, user_id: user_id),
         false <- expired_token?(ret),
         ^full_token <- rp_token do
      {:ok, ret}
    else
      _ -> {:error, {:not_found, full_token, "Token"}}
    end
  end

  @two_days 60 * 60 * 24 * 2
  defp expired_token?(%{inserted_at: date}) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), date) > @two_days
  end

  def confirm_email(token) do
    with {:ok, email_confirmation_token} <- get_email_confirmation_token(token) do
      user = Repo.get(User, email_confirmation_token.user_id)
      user_ch = User.confirm_email_changeset(user)

      Multi.new()
      |> Multi.delete(:email_confirmation_token, email_confirmation_token)
      |> Multi.update(:user, user_ch)
      |> Repo.transaction()
    end
  end

  defp get_email_confirmation_token(full_token) do
    with {:ok, {user_id, _}} <- MoodleNet.Token.split_id_and_token(full_token),
         ret = %{token: ec_token} <- Repo.get_by(EmailConfirmationToken, user_id: user_id),
         ^full_token <- ec_token do
      {:ok, ret}
    else
      _ -> {:error, {:not_found, full_token, "Token"}}
    end
  end

  def add_email_to_whitelist(email) do
    %WhitelistEmail{email: email}
    |> Repo.insert()
  end

  def remove_email_from_whitelist(email) do
    %WhitelistEmail{email: email}
    |> Repo.delete(stale_error_field: :email)
  end

  def is_email_in_whitelist?(email) do
    String.ends_with?(email, "@moodle.com") ||
      Repo.get(WhitelistEmail, email) != nil
  end

  defp set_default_icon(%{icon: _} = attrs), do: attrs
  defp set_default_icon(attrs) do
    if email = attrs["email"] || attrs[:email] do
      Map.put(attrs, :icon, %{type: "Image", url: MoodleNet.Gravatar.url(email)})
    else
      attrs
    end
  end
end
