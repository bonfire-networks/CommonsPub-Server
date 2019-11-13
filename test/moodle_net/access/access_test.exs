# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.AccessTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias Ecto.Changeset
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Test.Fake
  alias MoodleNet.Access
  alias MoodleNet.Access.{RegisterEmailDomainAccess, RegisterEmailAccess}

  describe "MoodleNet.Access.create_register_email_domain/1" do
    test "can be found with find_register_email_domain after success" do
      Repo.transaction(fn ->
        domain = Fake.domain()

        assert {:ok, %RegisterEmailDomainAccess{} = wl} =
                 Access.create_register_email_domain(domain)

        assert wl.domain == domain
        assert {:ok, wl} == Access.find_register_email_domain(domain)
      end)
    end

    test "fails helpfully with invalid data" do
      Repo.transaction(fn ->
        invalid = Fake.email()
        assert {:error, %Changeset{} = cs} = Access.create_register_email_domain(invalid)
        assert [{:domain, {"is of the wrong format", [validation: :format]}}] == cs.errors
      end)
    end
  end

  describe "MoodleNet.Access.create_register_email/1" do
    test "can be found with find_register_email after success" do
      Repo.transaction(fn ->
        email = Fake.email()
        assert {:ok, %RegisterEmailAccess{} = wl} = Access.create_register_email(email)
        assert wl.email == email
        assert {:ok, wl} == Access.find_register_email(email)
      end)
    end

    # TODO: validate emails better
    test "fails helpfully with invalid data" do
      Repo.transaction(fn ->
        invalid = Fake.icon()
        assert {:error, %Changeset{} = cs} = Access.create_register_email(invalid)
        assert [email: {"is of the wrong format", [validation: :format]}] == cs.errors
      end)
    end
  end

  describe "MoodleNet.Access.list_register_email_domains/0" do
    test "returns the correct data" do
      Repo.transaction(fn ->
        assert [] == Access.list_register_email_domains()
        a = fake_register_email_domain_access!()
        b = fake_register_email_domain_access!()
        assert ret = Access.list_register_email_domains()
        assert is_list(ret)
        assert Enum.sort([a, b]) == Enum.sort(ret)
      end)
    end
  end

  describe "MoodleNet.Access.list_register_emails/0" do
    test "returns the correct data" do
      Repo.transaction(fn ->
        assert [] == Access.list_register_emails()
        a = fake_register_email_access!()
        b = fake_register_email_access!()
        assert ret = Access.list_register_emails()
        assert is_list(ret)
        assert Enum.sort([a, b]) == Enum.sort(ret)
      end)
    end
  end

  describe "MoodleNet.Access.is_register_accessed?/1" do
    test "returns true when the email's domain is accessed" do
      Repo.transaction(fn ->
        domain = fake_register_email_domain_access!().domain
        email = Fake.email_user() <> "@" <> domain
        assert true == Access.is_register_accessed?(email)
      end)
    end

    test "returns true when the email is accessed" do
      Repo.transaction(fn ->
        email = fake_register_email_access!().email
        assert true == Access.is_register_accessed?(email)
      end)
    end

    test "returns false when no access pertains to the email" do
      Repo.transaction(fn ->
        assert false == Access.is_register_accessed?(Fake.email())
      end)
    end
  end

  describe "MoodleNet.Access.hard_delete/1" do
    test "raises :function_clause when given input of the wrong type" do
      Repo.transaction(fn ->
        assert :function_clause = catch_error(Access.hard_delete(Fake.uuid()))
      end)
    end

    test "returns a DeletionError passing a deleted model" do
      Repo.transaction(fn ->
        wl = fake_register_email_domain_access!()
        assert {:ok, deleted(wl)} == Access.hard_delete(wl)
        assert {:error, e} = Access.hard_delete(wl)
        assert was_already_deleted?(e)
      end)
    end

    test "can successfully delete a RegisterEmailDomainAccess" do
      Repo.transaction(fn ->
        wl = fake_register_email_domain_access!()
        assert {:ok, deleted(wl)} == Access.hard_delete(wl)
        assert {:error, %NotFoundError{} = e} = Access.find_register_email_domain(wl.domain)
        assert e.key == wl.domain
      end)
    end

    test "can successfully delete a RegisterEmailAccess" do
      Repo.transaction(fn ->
        wl = fake_register_email_access!()
        assert {:ok, deleted(wl)} == Access.hard_delete(wl)
        assert {:error, %NotFoundError{} = e} = Access.find_register_email(wl.email)
        assert e.key == wl.email
      end)
    end
  end

  describe "MoodleNet.Access.hard_delete!/1" do
    test "can successfully delete a RegisterEmailDomainAccess" do
      Repo.transaction(fn ->
        wl = fake_register_email_domain_access!()
        assert deleted(wl) == Access.hard_delete!(wl)
        assert {:error, %NotFoundError{} = e} = Access.find_register_email_domain(wl.domain)
        assert e.key == wl.domain
      end)
    end

    test "can successfully delete a RegisterEmailAccess" do
      Repo.transaction(fn ->
        wl = fake_register_email_access!()
        assert deleted(wl) == Access.hard_delete!(wl)
        assert {:error, %NotFoundError{} = e} = Access.find_register_email(wl.email)
        assert e.key == wl.email
      end)
    end

    test "throws a DeletionError passing a deleted model" do
      Repo.transaction(fn ->
        wl = fake_register_email_domain_access!()
        assert {:ok, deleted(wl)} == Access.hard_delete(wl)
        assert e = catch_throw(Access.hard_delete!(wl))
        assert was_already_deleted?(e)
      end)
    end
  end
end
