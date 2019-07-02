# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Accounts do
  @moduledoc """
  User Accounts context
  """

  require Ecto.Query
  alias MoodleNet.Repo
  alias Ecto.Multi
  alias Ecto.Query, as: EQuery
  alias MoodleNet.Accounts.{
    User,
    PasswordAuth,
    ResetPasswordToken,
    EmailConfirmationToken,
    WhitelistEmail
  }

  alias MoodleNet.{Mailer, Email, Token, Gravatar}

  alias ActivityPub.SQL.{Alter, Query}

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
    with {:ok, actor_attrs} <- register_actor_attrs(attrs) do

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
          # TODO: Properly implement welcome emails
          # |> Mailer.deliver_later()

        {:ok, email}
      end)
      |> Repo.transaction()
    end
  end

  defp register_actor_attrs(attrs) do
    attrs =
      attrs
      |> Map.put("type", "Person")
      |> Map.delete(:password)
      |> Map.delete("password")
      |> set_default_icon()
      |> set_default_image()
    username = Map.get(attrs, "preferred_username")

    cond do
      is_nil(username) -> {:ok, attrs}
      valid_username?(username) -> {:ok, attrs}
      true -> {:error, {:invalid_username, username}}
    end
  end

  # Usernames must be lowercase a-z 0-9 between 3 and 16 characters long
  defp valid_username?(username) when is_binary(username),
    do: Regex.match?(~r(^[a-z0-9]{3,16}$), username)
  defp valid_username?(_username), do: false

  # defp normalise_username(username) do
  #   name = String.downcase(Regex.replace(~r([^a-zA-Z0-9]+), username, ""))
  #   size = byte_size(name) # because of the alphabet, chars are 1 byte
  #   cond do
  #     size < 3 -> {:error, :username_too_short}
  #     size > 16 -> {:error, :username_too_long}
  #     true -> {:ok, name}
  #   end
  # end

  def update_user(actor, changes) do
    {icon_url, changes} = Map.pop(changes, :icon)
    {image_url, changes} = Map.pop(changes, :image)
    {location_content, changes} = Map.pop(changes, :location)
    {website, changes} = Map.pop(changes, :website)
    {username, changes} = Map.pop(changes, :preferred_username)
    icon = Query.new() |> Query.belongs_to(:icon, actor) |> Query.one()
    image = Query.new() |> Query.belongs_to(:image, actor) |> Query.one()
    location = Query.new() |> Query.belongs_to(:location, actor) |> Query.one()
    attachment = Query.new() |> Query.belongs_to(:attachment, actor) |> Query.one()
    # FIXME this should be a transaction
    with {:ok, _icon} <- ActivityPub.update(icon, url: icon_url),
         {:ok, _image} <- update_image(image, image_url, actor),
         {:ok, _location} <- update_location(location, location_content, actor),
         {:ok, _attachment} <- update_attachment(attachment, website, actor),
         {:ok, changes} <- update_username(actor, username, changes),
         {:ok, actor} <- ActivityPub.update(actor, changes) do
      # FIXME
      actor =
        ActivityPub.reload(actor)
        |> Query.preload_assoc([:icon, :image, :location, :attachment])

      {:ok, actor}
    end
  end

  defp update_username(actor, username, changes) do
    existing = Map.get(actor, :preferred_username)
    cond do
      is_nil(username) -> {:ok, changes}
      existing == username -> {:ok, changes}
      not is_nil(existing) -> {:error, :usernames_may_not_be_changed}
      not valid_username?(username) -> {:error, {:invalid_username, username}}
      not is_username_available?(username) -> {:error, :username_not_available}
      true -> {:ok, Map.put(changes, :preferred_username, username)}
    end
  end

  defp update_image(image, url, actor) do
    case image do
      nil ->
        with {:ok, image} <- ActivityPub.new(type: "Image", url: url),
             {:ok, image} <- ActivityPub.insert(image),
             {:ok, _} <- Alter.add(actor, :image, image),
             do: {:ok, image}
      image ->
        ActivityPub.update(image, url: url)
    end
  end

  defp update_location(nil, nil, _), do: {:ok, nil}

  defp update_location(location, nil, _) do
    ActivityPub.delete(location)
    {:ok, nil}
  end

  defp update_location(nil, content, actor) do
    with {:ok, location} <- ActivityPub.new(type: "Place", content: content),
         {:ok, location} <- ActivityPub.insert(location),
         {:ok, _} <- Alter.add(actor, :location, location),
         do: {:ok, location}
  end

  defp update_location(location, content, _) do
    ActivityPub.update(location, content: content)
  end

  defp update_attachment(nil, nil, _), do: {:ok, nil}

  defp update_attachment(attachment, nil, _) do
    ActivityPub.delete(attachment)
    {:ok, nil}
  end

  defp update_attachment(nil, changes, actor) do
    with {:ok, attachment} <- ActivityPub.new(%{
        name: "Website",
        type: "PropertyValue",
        value: changes
         }),
         {:ok, attachment} <- ActivityPub.insert(attachment),
         {:ok, _} <- Alter.add(actor, :attachment, attachment),
    do: {:ok, attachment}
  end

  defp update_attachment(attachment, changes, _) do
    ActivityPub.update(attachment, value: changes)
  end

  def delete_user(actor) do
    # FIXME this should be a transaction
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:attributed_to, actor)
    |> Query.update_all(set: [content: %{"und" => ""}])

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
    changeset = ResetPasswordToken.build_changeset(user)
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
    with {:ok, {user_id, _}} <- Token.split_id_and_token(full_token),
         ret = %{token: rp_token} <- Repo.get_by(ResetPasswordToken, user_id: user_id),
         false <- expired_token?(ret),
         ^full_token <- rp_token do
      {:ok, ret}
    else
      _ -> {:error, {:not_found, full_token, "Token"}}
    end
  end

  def is_username_available?(username) do
    ret =
      "activity_pub_actor_aspects"
      |> EQuery.where(
        [a],
        fragment("lower(?)", a.preferred_username) == fragment("lower(?)", ^username)
      )
      |> Repo.aggregate(:count, :local_id)

    ret == 0
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
    with {:ok, {user_id, _}} <- Token.split_id_and_token(full_token),
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
    String.ends_with?(email, "@moodle.com") || Repo.get(WhitelistEmail, email) != nil
  end

  defp set_default_icon(%{icon: _} = attrs), do: attrs

  defp set_default_icon(attrs) do
    if email = attrs["email"] || attrs[:email] do
      Map.put(attrs, :icon, %{type: "Image", url: Gravatar.url(email)})
    else
      attrs
    end
  end

  defp set_default_image(%{image: _} = attrs), do: attrs

  @default_image "https://images.unsplash.com/photo-1557943978-bea7e84f0e87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60"
  defp set_default_image(attrs) do
    Map.put(attrs, :image, %{type: "Image", url: @default_image})
  end
end
