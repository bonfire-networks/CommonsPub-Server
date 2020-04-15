# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.AccessTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.GraphQLFields
  import Grumble
  alias MoodleNet.Test.Fake
  alias MoodleNet.Access

  def email_access_fields(extra \\ []) do
    [:email, :created_at] ++ extra
  end

  def register_emails_query(options \\ []) do
    gen_query(:register_emails, &register_emails_subquery/1, options)
  end

  def register_emails_subquery(options \\ []) do
    gen_subquery(:register_emails, &email_access_fields/1, options)
  end

  def register_emails_page_query(options \\ []) do
    :limit
    |> gen_query(&register_emails_page_subquery/1, options)
  end

  def register_emails_page_subquery(options \\ []) do
    :limit
    |> page_subquery(:register_email_accesses, &email_access_fields/1, options)
  end

  def register_email_mutation(options \\ []) do
    [email: type!(:string)]
    |> gen_mutation(&register_email_submutation/1, options)
  end

  def register_email_submutation(options \\ []) do
    [email: var(:email)]
    |> gen_submutation(:create_register_email_access, &email_access_fields/1, options)
  end

  def domain_access_fields(extra \\ []) do
    [:domain, :created_at] ++ extra
  end

  def register_domain_page_query(options \\ []) do
    :limit
    |> gen_query(&register_domain_page_subquery/1, options)
  end

  def register_domain_page_subquery(options \\ []) do
    :limit
    |> page_subquery(:register_email_domain_accesses, &domain_access_fields/1, options)
  end

  def register_domain_mutation(options \\ []) do
    [domain: type!(:string)]
    |> gen_mutation(&register_domain_submutation/1, options)
  end

  def register_domain_submutation(options \\ []) do
    [domain: var(:domain)]
    |> gen_submutation(:create_register_email_domain_access, &domain_access_fields/1, options)
  end

  describe "register_email" do
    test "allows access by email" do
      user = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user)

      q = register_email_mutation()
      vars = %{email: Fake.email()}
      assert email_access = grumble_post_key(q, conn, :create_register_email_access, vars)
      assert email_access["email"] == vars[:email]
      assert email_access["createdAt"]
    end

    test "fails if access already exists" do
      user = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user)

      assert {:ok, email_access} = Access.create_register_email(Fake.email())

      q = register_email_mutation()

      assert [
               %{
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "Email already whitelisted",
                 "path" => ["createRegisterEmailAccess"]
               }
             ] = grumble_post_errors(q, conn, %{email: email_access.email})
    end

    test "retrieves page of emails" do
      user = fake_admin!()
      conn = user_conn(user)

      for email <- [Fake.email(), Fake.email(), Fake.email()] do
        Access.create_register_email(email)
      end

      q = register_emails_page_query()
      assert page = grumble_post_key(q, conn, :register_email_accesses, %{limit: 10})
      assert page["totalCount"] == 3
    end
  end

  describe "register_domain" do
    test "allows access by domain" do
      user = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user)

      q = register_domain_mutation()
      vars = %{domain: Fake.domain()}
      assert domain_access = grumble_post_key(q, conn, :create_register_email_domain_access, vars)
      assert domain_access["domain"] == vars[:domain]
      assert domain_access["createdAt"]
    end

    test "fails if domain already exists" do
      user = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user)

      assert {:ok, domain_access} = Access.create_register_email_domain(Fake.domain())

      q = register_domain_mutation()

      assert [
               %{
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "Domain already whitelisted",
                 "path" => ["createRegisterEmailDomainAccess"]
               }
             ] = grumble_post_errors(q, conn, %{domain: domain_access.domain})
    end

    test "retrieves page of domains" do
      user = fake_admin!()
      conn = user_conn(user)

      for domain <- [Fake.domain(), Fake.domain(), Fake.domain()] do
        Access.create_register_email_domain(domain)
      end

      q = register_domain_page_query()
      assert page = grumble_post_key(q, conn, :register_email_domain_accesses, %{limit: 10})
      assert page["totalCount"] == 3
    end
  end
end
