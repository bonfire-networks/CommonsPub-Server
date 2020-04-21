# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Fake do
  @moduledoc """
  A library of functions that generate fake data suitable for tests
  """
  import Zest.Faking

  # Basic data

  @integer_min -32768
  @integer_max 32767

  @file_fixtures [
    "test/fixtures/images/150.png",
    "test/fixtures/very-important.pdf",
  ]

  @url_fixtures [
    "https://duckduckgo.com",
    "https://moodle.com/moodlenet",
    "https://en.wikipedia.org/wiki/Boeing_727#Specifications",
    "https://upload.wikimedia.org/wikipedia/commons/5/57/B-727_Iberia_%28cropped%29.jpg",
  ]

  @doc "Returns true"
  def truth(), do: true
  @doc "Returns false"
  def falsehood(), do: false

  @doc "Generates a random boolean"
  def bool(), do: Faker.Util.pick([true, false])
  @doc "Generate a random signed integer"
  def integer(), do: Faker.random_between(@integer_min, @integer_max)
  @doc "Generate a random positive integer"
  def pos_integer(), do: Faker.random_between(0, @integer_max)
  @doc "Generate a random negative integer"
  def neg_integer(), do: Faker.random_between(@integer_min, 0)
  @doc "Generates a random url"
  def url(), do: Faker.Internet.url() <> "/"
  @doc "Picks a path from a set of available files."
  def path(), do: Faker.Util.pick(@file_fixtures)
  @doc "Picks a remote url from a set of available ones."
  def content_url(), do: Faker.Util.pick(@url_fixtures)
  @doc "Generate a random content type"
  def content_type(), do: Faker.File.mime_type()
  @doc "Picks a name"
  def name(), do: Faker.Company.name()
  @doc "Generates a random password string"
  def password(), do: base64()
  @doc "Generates a random date of birth based on an age range of 18-99"
  def date_of_birth(), do: Faker.Date.date_of_birth(18..99)
  @doc "Picks a date up to 300 days in the past, not including today"
  def past_date(), do: Faker.Date.backward(300)
  @doc "Picks a date up to 300 days in the future, not including today"
  def future_date(), do: Faker.Date.forward(300)
  @doc "Picks a datetime up to 300 days in the future, not including today"
  def future_datetime(), do: Faker.DateTime.forward(300)
  @doc "Generates a random paragraph"
  def paragraph(), do: Faker.Lorem.paragraph()
  @doc "Generates random base64 text"
  def base64(), do: Faker.String.base64()
  # def primary_language(), do: "en"

  # Custom data

  @doc "Picks a summary text paragraph"
  def summary(), do: paragraph()
  @doc "Picks an icon url"
  def icon(), do: Faker.Avatar.image_url()
  @doc "Picks an image url"
  def image(), do: Faker.Avatar.image_url()
  @doc "Picks a fake signing key"
  def signing_key(), do: nil
  @doc "A random license for content"
  def license(), do: Faker.Util.pick(["GPLv3", "BSDv3", "AGPL", "Creative Commons"])
  @doc "Returns a city and country"
  def location(), do: Faker.Address.city() <> " " <> Faker.Address.country()
  @doc "A website address"
  def website(), do: Faker.Internet.url()
  @doc "A verb to be used for an activity."
  def verb(), do: Faker.Util.pick(["created", "updated", "deleted"])

  # Unique data

  @doc "Generates a random unique uuid"
  def uuid(), do: unused(&Faker.UUID.v4/0, :uuid)
  @doc "Generates a random unique ulid"
  def ulid(), do: Ecto.ULID.generate()
  @doc "Generates a random unique email"
  def email(), do: unused(&Faker.Internet.email/0, :email)
  @doc "Generates a random domain name"
  def domain(), do: unused(&Faker.Internet.domain_name/0, :domain)
  @doc "Generates the first half of an email address"
  def email_user(), do: unused(&Faker.Internet.user_name/0, :email_user)
  @doc "Picks a unique random url for an ap endpoint"
  def ap_url_base(), do: unused(&url/0, :ap_url_base)
  @doc "Picks a unique preferred_username"
  def preferred_username(), do: unused(&Faker.Internet.user_name/0, :preferred_username)

  @doc "Picks a random canonical url and makes it unique"
  def canonical_url(), do: Faker.Internet.url() <> "/" <> ulid()

  # models

  def language(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &ulid/0) # todo: these can't both be right
    |> Map.put_new_lazy(:iso_code2, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:iso_code3, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:english_name, &Faker.Address.country/0)
    |> Map.put_new_lazy(:local_name, &Faker.Address.country/0)
  end

  def country(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &ulid/0) # todo: these can't both be right
    |> Map.put_new_lazy(:iso_code2, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:iso_code3, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:english_name, &Faker.Address.country/0)
    |> Map.put_new_lazy(:local_name, &Faker.Address.country/0)
  end

  def peer(base \\ %{}) do
    base
    |> Map.put_new_lazy(:ap_url_base, &ap_url_base/0)
    |> Map.put_new_lazy(:domain, &domain/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def activity(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:verb, &verb/0)
    |> Map.put_new_lazy(:is_local, &bool/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
  end

  def actor(base \\ %{}) do
    base
    |> Map.put_new_lazy(:preferred_username, &preferred_username/0)
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:signing_key, &signing_key/0)
  end

  def local_user(base \\ %{}) do
    base
    |> Map.put_new_lazy(:email, &email/0)
    |> Map.put_new_lazy(:password, &password/0)
    |> Map.put_new_lazy(:wants_email_digest, &bool/0)
    |> Map.put_new_lazy(:wants_notifications, &bool/0)
    |> Map.put_new_lazy(:is_instance_admin, &falsehood/0)
    |> Map.put_new_lazy(:is_confirmed, &falsehood/0)
  end

  def user(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:website, &website/0)
    |> Map.put_new_lazy(:location, &location/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.merge(actor(base))
    |> Map.merge(local_user(base))
  end

  def registration_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("email", &email/0)
    |> Map.put_new_lazy("password", &password/0)
    |> Map.put_new_lazy("preferredUsername", &preferred_username/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
    |> Map.put_new_lazy("location", &location/0)
    |> Map.put_new_lazy("website", &website/0)
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("wantsEmailDigest", &bool/0)
    |> Map.put_new_lazy("wantsNotifications", &bool/0)
  end

  def profile_update_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
    |> Map.put_new_lazy("location", &location/0)
    |> Map.put_new_lazy("website", &website/0)
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("wantsEmailDigest", &bool/0)
    |> Map.put_new_lazy("wantsNotifications", &bool/0)
  end

  def community(base \\ %{}) do
    base
    # |> Map.put_new_lazy(:primary_language_id, &ulid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.put_new_lazy(:is_featured, &bool/0)
    |> Map.merge(actor(base))
  end

  def community_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("preferredUsername", &preferred_username/0)
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
  end

  def community_update_input(base \\ %{}) do
    base
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
  end

  def collection(base \\ %{}) do
    base
    # |> Map.put_new_lazy(:primary_language_id, &ulid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.put_new_lazy(:is_featured, &bool/0)
    |> Map.merge(actor(base))
  end

  def collection_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("preferredUsername", &preferred_username/0)
    |> collection_update_input()
  end

  def collection_update_input(base \\ %{}) do
    base
    # |> Map.put_new_lazy("primaryLanguageId", &ulid/0)
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
  end

  def resource(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:license, &license/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_hidden, &falsehood/0)
  end

  def resource_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("summary", &summary/0)
    |> Map.put_new_lazy("license", &license/0)
    # |> Map.put_new_lazy("freeAccess", &maybe_bool/0)
    # |> Map.put_new_lazy("publicAccess", &maybe_bool/0)
    # |> Map.put_new_lazy("learningResourceType", &learning_resource/0)
    # |> Map.put_new_lazy("educationalUse", &educational_use/0)
    # |> Map.put_new_lazy("timeRequired", &pos_integer/0)
    # |> Map.put_new_lazy("typicalAgeRange", &age_range/0)
    # |> Map.put_new_lazy("primaryLanguageId", &primary_language/0)
  end

  def thread(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_locked, &falsehood/0)
    |> Map.put_new_lazy(:is_hidden, &falsehood/0)
  end

  def comment(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:content, &paragraph/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_local, &bool/0)
    |> Map.put_new_lazy(:is_hidden, &falsehood/0)
    |> Map.put_new_lazy(:content, &paragraph/0)
  end

  def comment_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("content", &paragraph/0)
  end

  def like(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
  end

  def like_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def feature_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def flag(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:message, &paragraph/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_resolved, &falsehood/0)
  end

  def flag_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:message, &paragraph/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def follow(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_muted, &falsehood/0)
  end

  def follow_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_local, &truth/0)
  end

  def block(base \\ %{}) do
    base
    |> Map.put_new_lazy(:canonical_url, &canonical_url/0)
    |> Map.put_new_lazy(:is_local, &truth/0)
    |> Map.put_new_lazy(:is_blocked, &truth/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_muted, &falsehood/0)
  end

  # def tag(base \\ %{}) do
  #   base
  #   |> Map.put_new_lazy(:is_public, &truth/0)
  #   |> Map.put_new_lazy(:name, &name/0)
  # end

  # def community_role(base \\ %{}) do
  #   base
  # end

  def content_mirror_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:url, &content_url/0)
  end

  def content_upload_input(base \\ %{}) do
    base
    |> Map.put_new_lazy(:upload, fn ->
      path = path()
      %Plug.Upload{
        path: path,
        filename: Path.basename(path),
        content_type: content_type(),
      }
    end)
  end

  def content_input(base \\ %{}) do
    gen = Faker.Util.pick([&content_mirror_input/1, &content_upload_input/1])
    gen.(base)
  end
end
