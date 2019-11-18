# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.ChangesetTest do
  use ExUnit.Case, async: true

  import MoodleNet.Common.Changeset
  alias Ecto.Changeset

  defmodule Dummy do
    use MoodleNet.Common.Schema

    standalone_schema "dummy" do
      field(:url, :string)
      field(:email, :string)
      field(:email_domain, :string)
      field(:expires_at, :utc_datetime_usec)
      field(:published_at, :utc_datetime_usec)
      field(:is_public, :boolean, virtual: true)
      field(:deleted_at, :utc_datetime_usec)
    end

    @cast ~w(url email email_domain is_public expires_at)a

    def cast(params), do: Changeset.cast(%__MODULE__{}, params, @cast)
  end

  describe "validate_http_url/2" do
    test "succeeds if provided a valid URL" do
      invalid = [
        "http://elixir-lang.org",
        "https://elixir-lang.org/",
        "https://elixir-lang.org/foo/bar"
      ]

      for url <- invalid do
        changeset = %{url: url} |> Dummy.cast() |> validate_http_url(:url)
        refute Keyword.get(changeset.errors, :url)
      end
    end

    test "fails if provided an invalid URL" do
      invalid = [
        "//elixir-lang.org/",
        "ftp://elixir-lang.org",
        "http:///test"
      ]

      for url <- invalid do
        changeset = %{url: url} |> Dummy.cast() |> validate_http_url(:url)
        assert Keyword.get(changeset.errors, :url)
      end
    end
  end

  describe "validate_email/2" do
    test "succeeds when provided with a valid email" do
      valid = [
        "testy@example.com",
        "testy.testface@example.com",
        "test@mail.example.com"
      ]

      for email <- valid do
        changeset = %{email: email} |> Dummy.cast() |> validate_email(:email)
        refute Keyword.get(changeset.errors, :email), "Email should be valid: #{email}"
      end
    end

    test "fails when provided with a bogus email" do
      invalid = [
        "test@localhost",
        "test@localhost:6969"
        # FIXME
        # "test(@live).net/235",
        # "test#bla^\\?:*/!&^@@example.@.com"
      ]

      for email <- invalid do
        changeset = %{email: email} |> Dummy.cast() |> validate_email(:email)
        assert Keyword.get(changeset.errors, :email), "Email should be invalid: #{email}"
      end
    end
  end

  describe "validate_email_domain/2" do
    test "succeeds when provided with a valid email domain" do
      valid = ["example.com", "mail.example.com"]

      for domain <- valid do
        changeset =
          %{email_domain: domain}
          |> Dummy.cast()
          |> validate_email_domain(:email_domain)

        refute Keyword.get(changeset.errors, :email_domain),
               "Email domain should be valid: #{domain}"
      end
    end

    test "fails when provided with a bogus email domain" do
      invalid = ["example.com:6969", "example.com/with_path?and_queries=true"]

      for domain <- invalid do
        changeset =
          %{email_domain: domain}
          |> Dummy.cast()
          |> validate_email_domain(:email_domain)

        assert Keyword.get(changeset.errors, :email_domain),
               "Email domain should be invalid: #{domain}"
      end
    end
  end

  describe "validate_not_expired/3" do
    test "succeeds when not expired" do
      changeset =
        %{expires_at: Faker.DateTime.forward(30)}
        |> Dummy.cast()
        |> validate_not_expired()

      refute Keyword.get(changeset.errors, :expires_at)
    end

    test "can provide a datetime for current time" do
      changeset =
        %{expires_at: DateTime.utc_now()}
        |> Dummy.cast()
        |> validate_not_expired(Faker.DateTime.backward(7))

      refute Keyword.get(changeset.errors, :expires_at)
    end

    test "fails when the expired date has passed" do
      changeset =
        %{expires_at: Faker.DateTime.backward(1)}
        |> Dummy.cast()
        |> validate_not_expired()

      assert Keyword.get(changeset.errors, :expires_at)
    end
  end

  describe "soft_delete_changeset/3" do
    test "updates the deletion date if not already set" do
      changeset = %{} |> Dummy.cast() |> soft_delete_changeset()
      assert :lt = DateTime.compare(changeset.changes.deleted_at, DateTime.utc_now())
    end

    test "fails if it has already been deleted" do
      changeset =
        %{}
        |> Dummy.cast()
        # twice
        |> soft_delete_changeset()
        |> soft_delete_changeset()

      assert Keyword.get(changeset.errors, :deleted_at)
    end
  end

  describe "change_public/1" do
    test "changes a published timestamp when is_public changes" do
      changeset =
        %{is_public: true}
        |> Dummy.cast()
        |> change_public()

      assert changeset.changes.published_at

      changeset =
        changeset
        |> Changeset.change(%{is_public: false})
        |> change_public()

      refute changeset.changes.is_public
    end
  end
end
