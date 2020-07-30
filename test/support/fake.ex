# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Fake do
  @moduledoc """
  A library of functions that generate fake data suitable for tests
  """
  import CommonsPub.Utils.Simulation

  # models

  def language(base \\ %{}) do
    base
    # todo: these can't both be right
    |> Map.put_new_lazy(:id, &ulid/0)
    |> Map.put_new_lazy(:iso_code2, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:iso_code3, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:english_name, &Faker.Address.country/0)
    |> Map.put_new_lazy(:local_name, &Faker.Address.country/0)
  end

  def country(base \\ %{}) do
    base
    # todo: these can't both be right
    |> Map.put_new_lazy(:id, &ulid/0)
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
    |> Map.put_new_lazy("email", &email/0)
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
    |> Map.put("subject", "2290")
    |> Map.put("level", "1100")
    |> Map.put("language", "English")

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
        content_type: content_type()
      }
    end)
  end

  def content_input(base \\ %{}) do
    gen = Faker.Util.pick([&content_mirror_input/1, &content_upload_input/1])
    gen.(base)
  end
end
