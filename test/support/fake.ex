# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Fake do
  @moduledoc """
  A library of functions that generate fake data suitable for tests
  """
  @doc """
  Reruns a faker until a predicate passes.
  Default limit is 10 tries.
  """
  def such_that(faker, name, test, limit \\ 10)

  def such_that(faker, name, test, limit)
      when is_integer(limit) and limit > 0 do
    fake = faker.()

    if test.(fake),
      do: fake,
      else: such_that(faker, name, test, limit - 1)
  end

  def such_that(_faker, name, _test, _limit) do
    throw({:tries_exceeded, name})
  end

  @doc """
  Reruns a faker until an unseen value has been generated.
  Default limit is 10 tries.
  Stores seen things in the process dict (yes, *that* process dict)
  """
  def unused(faker, name, limit \\ 10)
  def unused(_faker, name, 0), do: throw({:error, {:tries_exceeded, name}})

  def unused(faker, name, limit) when is_integer(limit) do
    used = get_used(name)
    fake = such_that(faker, name, &(&1 not in used))
    forbid(name, [fake])
    fake
  end

  @doc """
  Partner to `unused`. Adds a list of values to the list of used
  values under a key.
  """
  def forbid(name, values) when is_list(values) do
    set_used(name, values ++ get_used(name))
  end

  @doc """
  Returns the next unused integer id for `name` starting from `start`.
  Permits jumping by artificially increasing start - if start is
  higher than the last used id, it will return start and set it as the
  last used id
  """
  def sequential(name, start) when is_integer(start) do
    val = nextval(get_seq(name, start - 1), start)
    set_seq(name, val)
    val
  end

  # Basic data

  @integer_min -32768
  @integer_max 32767

  @doc "Generates a random boolean"
  def bool(), do: Faker.Util.pick([true, false])
  @doc "Generate a random boolean that set to nil"
  def maybe_bool(), do: Faker.Util.pick([true, false, nil])
  @doc "Generate a random signed integer"
  def integer(), do: Faker.random_between(@integer_min, @integer_max)
  @doc "Generate a random positive integer"
  def pos_integer(), do: Faker.random_between(0, @integer_max)
  @doc "Generate a random negative integer"
  def neg_integer(), do: Faker.random_between(@integer_min, 0)
  @doc "Generates a random url"
  def url(), do: Faker.Internet.url() <> "/"
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

  # Custom data

  @doc "Picks a summary text paragraph"
  def summary(), do: paragraph()
  @doc "Picks an icon url"
  def icon(), do: Faker.Avatar.image_url()
  @doc "Picks an image url"
  def image(), do: Faker.Avatar.image_url()
  @doc "Picks a fake signing key"
  def signing_key(), do: base64()
  @doc "A random license for content"
  def license(), do: Faker.Util.pick(["GPLv3", "BSDv3", "AGPL", "Creative Commons"])
  @doc "A list of random education uses"
  def educational_use(),
    do: [Faker.Industry.industry(), Faker.Industry.sector(), Faker.Industry.sub_sector()]
  @doc "Picks a learning resource type"
  def learning_resource(), do: Faker.Util.pick(["video", "podcast", "article", "paper"])
  @doc "Picks an age range, represented as a string"
  def age_range(), do: "#{Faker.random_between(6, 15)}-#{Faker.random_between(16, 100)}"
  @doc "Returns a city and country"
  def location(), do: Faker.Address.city() <> " " <> Faker.Address.country()
  @doc "A website address"
  def website(), do: Faker.Internet.url()
  @doc "A language name (not really)"
  def language(), do: Faker.Address.country()

  # Unique data

  @doc "Generates a random unique uuid"
  def uuid(), do: unused(&Faker.UUID.v4/0, :uuid)
  @doc "Generates a random unique email"
  def email(), do: unused(&Faker.Internet.email/0, :email)
  @doc "Generates a random domain name"
  def domain(), do: unused(&Faker.Internet.domain_name/0, :domain)
  @doc "Generates the first half of an email address"
  def email_user(), do: unused(&Faker.Internet.user_name/0, :preferred_username)
  @doc "Picks a unique random url for an ap endpoint"
  def ap_url_base(), do: unused(&url/0, :ap_url_base)
  @doc "Picks a unique preferred_username"
  def preferred_username(), do: unused(&Faker.Internet.user_name/0, :preferred_username)

  # models

  def primary_language(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &Faker.Address.country_code/0)
    |> Map.put_new_lazy(:english_name, &Faker.Address.country/0)
    |> Map.put_new_lazy(:local_name, &Faker.Address.country/0)
  end

  def peer(base \\ %{}) do
    base
    |> Map.put_new_lazy(:ap_url_base, &ap_url_base/0)
  end

  def actor(base \\ %{}) do
    base
    |> Map.put_new_lazy(:preferred_username, &preferred_username/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:location, &location/0)
    |> Map.put_new_lazy(:website, &website/0)
    |> Map.put_new_lazy(:icon, &icon/0)
    |> Map.put_new_lazy(:image, &image/0)
    |> Map.put_new_lazy(:primary_language, &image/0)
    |> Map.put_new_lazy(:signing_key, &signing_key/0)
    |> Map.put_new_lazy(:is_public, &bool/0)
  end

  def user(base \\ %{}) do
    base
    |> Map.put_new_lazy(:email, &email/0)
    |> Map.put_new_lazy(:password, &password/0)
    |> Map.put_new_lazy(:wants_email_digest, &bool/0)
    |> Map.put_new_lazy(:wants_notifications, &bool/0)
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
    |> Map.put_new_lazy("icon", &icon/0)
    |> Map.put_new_lazy("image", &image/0)
    |> Map.put_new_lazy("primary_language", &image/0)
    |> Map.put_new_lazy("is_public", &bool/0)
    |> Map.put_new_lazy("wants_email_digest", &bool/0)
    |> Map.put_new_lazy("wants_notifications", &bool/0)
  end

  def community(base \\ %{}) do
    # TODO: add relations
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
  end

  def collection(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
  end

  def resource(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
    |> Map.put_new_lazy(:content, &paragraph/0)
    |> Map.put_new_lazy(:url, &url/0)
    |> Map.put_new_lazy(:free_access, &maybe_bool/0)
    |> Map.put_new_lazy(:public_access, &maybe_bool/0)
    |> Map.put_new_lazy(:license, &license/0)
    |> Map.put_new_lazy(:learning_resource_type, &learning_resource/0)
    |> Map.put_new_lazy(:educational_use, &educational_use/0)
    |> Map.put_new_lazy(:time_required, &pos_integer/0)
    |> Map.put_new_lazy(:typical_age_range, &age_range/0)
  end

  def thread(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
  end

  def comment(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
    |> Map.put_new_lazy(:content, &paragraph/0)
  end

  def flag(base \\ %{}) do
    base
    |> Map.put_new_lazy(:message, &paragraph/0)
  end

  def follow(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
    |> Map.put_new_lazy(:is_muted, &bool/0)
  end

  def block(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
    |> Map.put_new_lazy(:is_muted, &bool/0)
    |> Map.put_new_lazy(:is_blocked, &bool/0)
  end

  def tag(base \\ %{}) do
    base
    |> Map.put_new_lazy(:is_public, &bool/0)
    |> Map.put_new_lazy(:name, &name/0)
  end

  # def community_role(base \\ %{}) do
  #   base
  # end

  # def

  # Support for `unused/3`

  @doc false
  def used_key(name), do: {__MODULE__, {:used, name}}
  @doc false
  def get_used(name), do: Process.get(used_key(name), [])
  @doc false
  def set_used(name, used) when is_list(used), do: Process.put(used_key(name), used)

  # support for `sequential/2`

  defp nextval(id, start)
  defp nextval(nil, start), do: start
  defp nextval(id, start) when id < start, do: start
  defp nextval(id, _), do: id + 1

  defp seq_key(name), do: {__MODULE__, {:seq, name}}
  defp get_seq(name, default), do: Process.get(seq_key(name), default)
  defp set_seq(name, seq) when is_integer(seq), do: Process.put(seq_key(name), seq)

end
