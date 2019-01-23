defmodule MoodleNet.AccountsTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Accounts
  alias MoodleNet.Accounts.{User, ResetPasswordToken}

  describe "register_user" do
    test "works" do
      icon_attrs = Factory.attributes(:image)

      attrs =
        Factory.attributes(:user)
        |> Map.put("icon", icon_attrs)
        |> Map.put("extra_field", "extra")

      Accounts.add_email_to_whitelist(attrs["email"])
      assert {:ok, ret} = Accounts.register_user(attrs)
      assert attrs["email"] == ret.user.email
      assert ret.actor
      assert attrs["preferred_username"] == ret.actor.preferred_username
      assert ret.actor["extra_field"] == attrs["extra_field"]
      assert [icon] = ret.actor[:icon]
      assert [icon_attrs["url"]] == get_in(ret, [:actor, :icon, Access.at(0), :url])

      assert_delivered_email(MoodleNet.Email.welcome(ret.user, ret.email_confirmation_token.token))
    end

    test "fails with invalid password values" do
      attrs = Factory.attributes(:user) |> Map.delete("password")
      Accounts.add_email_to_whitelist(attrs["email"])
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "can't be blank" in errors_on(ch).password

      attrs = Factory.attributes(:user) |> Map.put("password", "short")
      Accounts.add_email_to_whitelist(attrs["email"])
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "should be at least 6 character(s)" in errors_on(ch).password
    end

    test "fails with invalid email" do
      attrs = Factory.attributes(:user) |> Map.delete("email")
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "can't be blank" in errors_on(ch).email

      attrs = Factory.attributes(:user) |> Map.put("email", "not_an_email")
      Accounts.add_email_to_whitelist(attrs["email"])
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "has invalid format" in errors_on(ch).email
    end

    test "lower case the email" do
      attrs = Factory.attributes(:user)
      email = attrs["email"]
      attrs = Map.put(attrs, "email", String.upcase(attrs["email"]))
      Accounts.add_email_to_whitelist(attrs["email"])
      assert {:ok, ret} = Accounts.register_user(attrs)
      assert ret.user.email == email
    end
  end

  describe "authenticate_by_email_and_pass" do
    test "works" do
      user = %{id: user_id} = Factory.user()

      assert {:ok, %User{id: ^user_id}} =
               Accounts.authenticate_by_email_and_pass(user.email, "password")

      assert {:error, :unauthorized} =
               Accounts.authenticate_by_email_and_pass(user.email, "other_thing")

      assert {:error, :not_found} =
               Accounts.authenticate_by_email_and_pass("other@email.es", "password")
    end
  end

  describe "reset_password_request" do
    test "works" do
      user = Factory.user()
      assert {:ok, %{token: token}} = Accounts.reset_password_request(user.email)

      assert %{token: ^token} = Repo.get_by!(ResetPasswordToken, user_id: user.id)

      assert_delivered_email(MoodleNet.Email.reset_password_request(user, token))

      assert {:ok, %{token: new_token}} = Accounts.reset_password_request(user.email)
      assert %{token: ^new_token} = Repo.get_by!(ResetPasswordToken, user_id: user.id)
      assert token != new_token
    end

    test "returns error if email not found" do
      assert {:error, {:not_found, "not_found", "User"}} = Accounts.reset_password_request("not_found")
    end
  end

  describe "reset_password" do
    test " works" do
      user = Factory.user()
      assert {:ok, %{token: token}} = Accounts.reset_password_request(user.email)
      assert {:ok, _} = Accounts.reset_password(token, "new_password")

      refute Repo.get_by(ResetPasswordToken, user_id: user.id)
      assert {:ok, _} = Accounts.authenticate_by_email_and_pass(user.email, "new_password")

      assert_delivered_email(MoodleNet.Email.password_reset(user))
    end

    test "returns error with invalid password" do
      user = Factory.user()
      assert {:ok, %{token: token}} = Accounts.reset_password_request(user.email)
      assert {:error, :password_hash, ch, _} = Accounts.reset_password(token, "short")
      assert "should be at least 6 character(s)" in errors_on(ch)[:password]
    end

    @three_days 60 * 60 * 24 * 3
    test "returns error with expired tokens" do
      user = Factory.user()

      token = MoodleNet.Token.random_key_with_id(user.id)
      date =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)
        |> NaiveDateTime.add(-@three_days)
      token = Repo.insert!(%ResetPasswordToken{token: token, user_id: user.id, inserted_at: date})

      assert {:error, {:not_found, _, "Token"}} = Accounts.reset_password(token.token, "new_password")
    end

    test "returns error if token not found" do
      assert {:error, {:not_found, _, "Token"}} = Accounts.reset_password("1234", "new_password")

      user = Factory.user()
      token = MoodleNet.Token.random_key_with_id(user.id)
      assert {:error, {:not_found, _, "Token"}} = Accounts.reset_password(token, "new_password")

      assert {:ok, %{token: token}} = Accounts.reset_password_request(user.email)
      assert {:error, {:not_found, _, "Token"}} = Accounts.reset_password(token <> "1", "new_password")
    end
  end

  describe "confirm_email" do
    test "works" do
      %{user: user, email_confirmation_token: %{token: token}} = Factory.full_user()
      assert {:ok, _} = Accounts.confirm_email(token)
      refute user.confirmed_at
      assert Repo.get(User, user.id).confirmed_at
      refute Repo.get_by(Accounts.EmailConfirmationToken, user_id: user.id)
    end

    test "returns error if token not found" do
      assert {:error, {:not_found, "1234", "Token"}} = Accounts.confirm_email("1234")

      %{user: user, email_confirmation_token: %{token: token}} = Factory.full_user()
      assert {:error, {:not_found, _, "Token"}} = Accounts.confirm_email(MoodleNet.Token.random_key_with_id(user.id))
      assert {:error, {:not_found, _, "Token"}} = Accounts.confirm_email(token <> "1")
    end
  end

  describe "whitelist" do
    test "works" do
      email = Faker.Internet.safe_email()
      refute Accounts.is_email_in_whitelist?(email)
      assert {:ok, _} = Accounts.add_email_to_whitelist(email)
      assert Accounts.is_email_in_whitelist?(email)
      assert {:ok, _} = Accounts.remove_email_from_whitelist(email)
      refute Accounts.is_email_in_whitelist?(email)
      assert {:error, _} = Accounts.remove_email_from_whitelist(email)
    end
  end
end
