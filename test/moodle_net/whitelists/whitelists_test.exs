# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.WhitelistsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias Ecto.Changeset
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Test.Fake
  alias MoodleNet.Whitelists
  alias MoodleNet.Whitelists.{RegisterEmailDomainWhitelist, RegisterEmailWhitelist}

  describe "MoodleNet.Whitelists.create_register_email_domain/1" do

    test "can be found with find_register_email_domain after success" do
      Repo.transaction fn ->
	domain = Fake.domain()
        assert {:ok, %RegisterEmailDomainWhitelist{}=wl} =
	  Whitelists.create_register_email_domain(domain)
	assert wl.domain == domain
	assert {:ok, wl} == Whitelists.find_register_email_domain(domain)
      end
    end

    # TODO: we should validate the domain
    @tag :skip
    test "fails helpfully with invalid data" do
      Repo.transaction fn ->
	invalid = Fake.icon()
	assert {:error, %Changeset{}=cs} = 
	  Whitelists.create_register_email_domain(invalid)
	assert [{:domain, "has invalid format", [validation: :format]}] == cs.errors
      end
    end

  end

  describe "MoodleNet.Whitelists.create_register_email/1" do

    test "can be found with find_register_email after success" do
      Repo.transaction fn ->
	email = Fake.email()
        assert {:ok, %RegisterEmailWhitelist{}=wl} =
	  Whitelists.create_register_email(email)
	assert wl.email == email
	assert {:ok, wl} == Whitelists.find_register_email(email)
      end
    end

    # TODO: validate emails better
    test "fails helpfully with invalid data" do
      Repo.transaction fn ->
	invalid = Fake.icon()
	assert {:error, %Changeset{}=cs} = 
	  Whitelists.create_register_email(invalid)
	assert [email: {"has invalid format", [validation: :format]}] == cs.errors
      end
    end

  end

  describe "MoodleNet.Whitelists.list_register_email_domains/0" do
  
    test "returns the correct data" do
      Repo.transaction fn ->
	assert [] == Whitelists.list_register_email_domains()
	a = fake_register_email_domain_whitelist!()
	b = fake_register_email_domain_whitelist!()
	assert ret = Whitelists.list_register_email_domains()
	assert is_list(ret)
	assert Enum.sort([a,b]) == Enum.sort(ret)
      end
    end

  end

  describe "MoodleNet.Whitelists.list_register_emails/0" do

    test "returns the correct data" do
      Repo.transaction fn ->
	assert [] == Whitelists.list_register_emails()
	a = fake_register_email_whitelist!()
	b = fake_register_email_whitelist!()
	assert ret = Whitelists.list_register_emails()
	assert is_list(ret)
	assert Enum.sort([a,b]) == Enum.sort(ret)
      end
    end

  end

  describe "MoodleNet.Whitelists.is_register_whitelisted?/1" do

    test "returns true when the email's domain is whitelisted" do
      Repo.transaction fn ->
	domain = fake_register_email_domain_whitelist!().domain
	email = Fake.email_user() <> "@" <> domain
	assert true == Whitelists.is_register_whitelisted?(email)
      end
    end

    test "returns true when the email is whitelisted" do
      Repo.transaction fn ->
	email = fake_register_email_whitelist!().email
	assert true == Whitelists.is_register_whitelisted?(email)
      end
    end

    test "returns false when no whitelist pertains to the email" do
      Repo.transaction fn ->
	assert false == Whitelists.is_register_whitelisted?(Fake.email())
      end
    end

  end

  describe "MoodleNet.Whitelists.hard_delete/1" do

    test "raises :function_clause when given input of the wrong type" do
      Repo.transaction fn ->
	assert :function_clause = catch_error(Whitelists.hard_delete(Fake.uuid()))
      end
    end

    test "returns a DeletionError passing a deleted model" do
      Repo.transaction fn ->
        wl = fake_register_email_domain_whitelist!()
        assert {:ok, deleted(wl)} == Whitelists.hard_delete(wl)
	assert {:error, e} = Whitelists.hard_delete(wl)
	assert was_already_deleted?(e)
      end
    end

    test "can successfully delete a RegisterEmailDomainWhitelist" do
      Repo.transaction fn ->
        wl = fake_register_email_domain_whitelist!()
        assert {:ok, deleted(wl)} == Whitelists.hard_delete(wl)
        assert {:error, %NotFoundError{}=e} =
	  Whitelists.find_register_email_domain(wl.domain)
	assert e.key == wl.domain
      end
    end

    test "can successfully delete a RegisterEmailWhitelist" do
      Repo.transaction fn ->
        wl = fake_register_email_whitelist!()
        assert {:ok, deleted(wl)} == Whitelists.hard_delete(wl)
        assert {:error, %NotFoundError{}=e} =
	  Whitelists.find_register_email(wl.email)
	assert e.key == wl.email
      end
    end

  end

  describe "MoodleNet.Whitelists.hard_delete!/1" do
  
    test "can successfully delete a RegisterEmailDomainWhitelist" do
      Repo.transaction fn ->
        wl = fake_register_email_domain_whitelist!()
        assert deleted(wl) == Whitelists.hard_delete!(wl)
        assert {:error, %NotFoundError{}=e} =
	  Whitelists.find_register_email_domain(wl.domain)
	assert e.key == wl.domain
      end
    end


    test "can successfully delete a RegisterEmailWhitelist" do
      Repo.transaction fn ->
        wl = fake_register_email_whitelist!()
        assert deleted(wl) == Whitelists.hard_delete!(wl)
        assert {:error, %NotFoundError{}=e} =
	  Whitelists.find_register_email(wl.email)
	assert e.key == wl.email
      end
    end

    test "throws a DeletionError passing a deleted model" do
      Repo.transaction fn ->
        wl = fake_register_email_domain_whitelist!()
        assert {:ok, deleted(wl)} == Whitelists.hard_delete(wl)
	assert e = catch_throw(Whitelists.hard_delete!(wl))
	assert was_already_deleted?(e)
      end
    end

  end

end
