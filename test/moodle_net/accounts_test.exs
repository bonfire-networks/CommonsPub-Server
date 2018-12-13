defmodule MoodleNet.AccountsTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Accounts
  alias MoodleNet.Accounts.{User}

  describe "register_user" do
    test "works" do
      icon_attrs = Factory.attributes(:image)
      attrs = Factory.attributes(:user)
              |> Map.put("icon", icon_attrs)
              |> Map.put("extra_field", "extra")
      assert {:ok, ret} = Accounts.register_user(attrs)
      assert attrs["email"] == ret.user.email
      assert ret.actor
      assert attrs["preferred_username"] == ret.actor.preferred_username
      assert ret.actor["extra_field"] == attrs["extra_field"]
      assert [icon] = ret.actor[:icon]
      assert [icon_attrs["url"]] == get_in(ret, [:actor, :icon, Access.at(0), :url])
    end

    test "fails with invalid password values" do
      attrs = Factory.attributes(:user) |> Map.delete("password")
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "can't be blank" in errors_on(ch).password

      attrs = Factory.attributes(:user) |> Map.put("password", "short")
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "should be at least 6 character(s)" in errors_on(ch).password
    end

    test "fails with invalid email" do
      attrs = Factory.attributes(:user) |> Map.delete("email")
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "can't be blank" in errors_on(ch).email

      attrs = Factory.attributes(:user) |> Map.put("email", "not_an_email")
      assert {:error, _, ch, _} = Accounts.register_user(attrs)
      assert "has invalid format" in errors_on(ch).email
    end

    test "lower case the email" do
      attrs = Factory.attributes(:user)
      email = attrs["email"]
      attrs = Map.put(attrs, "email", String.upcase(attrs["email"]))
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
end
