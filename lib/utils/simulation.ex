defmodule CommonsPub.Utils.Simulation do
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
  @doc "Picks a datetime up to 300 days in the past, not including today"
  def past_datetime(), do: Faker.DateTime.backward(300)
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
  def uuid(), do: Zest.Faking.unused(&Faker.UUID.v4/0, :uuid)
  @doc "Generates a random unique ulid"
  def ulid(), do: Ecto.ULID.generate()
  @doc "Generates a random unique email"
  def email(), do: Zest.Faking.unused(&Faker.Internet.email/0, :email)
  @doc "Generates a random domain name"
  def domain(), do: Zest.Faking.unused(&Faker.Internet.domain_name/0, :domain)
  @doc "Generates the first half of an email address"
  def email_user(), do: Zest.Faking.unused(&Faker.Internet.user_name/0, :email_user)
  @doc "Picks a unique random url for an ap endpoint"
  def ap_url_base(), do: Zest.Faking.unused(&url/0, :ap_url_base)
  @doc "Picks a unique preferred_username"
  def preferred_username(),
    do: Zest.Faking.unused(&Faker.Internet.user_name/0, :preferred_username)

  @doc "Picks a random canonical url and makes it unique"
  def canonical_url(), do: Faker.Internet.url() <> "/" <> ulid()
end
