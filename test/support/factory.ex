defmodule MoodleNet.Factory do
  def attributes(:user) do
    name = Faker.Name.name()

    %{
      "email" => Faker.Internet.safe_email(),
      "name" => name,
      "username" => name |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "_"),
      "password" => "password",
      "locale" => "es"
    }
  end

  def attributes(:oauth_app) do
    url = Faker.Internet.url()
    %{
      "client_name" => Faker.App.name(),
      "redirect_uri" => url,
      "scopes" => "read",
      "website" => url,
      "client_id" => url,
    }
  end

  def attributes(factory_name, attrs) do
    attrs =
      Enum.into(attrs, %{}, fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), v}
        {k, v} when is_binary(k) -> {k, v}
      end)

    factory_name
    |> attributes()
    |> Map.merge(attrs)
  end

  alias MoodleNet.Accounts

  def actor(attrs \\ %{}) do
    attrs = attributes(:user, attrs)

    {:ok, %{actor: actor}} =
      Ecto.Multi.new()
      |> ActivityPub.create_actor(attrs)
      |> MoodleNet.Repo.transaction()

    actor
  end

  def user(attrs \\ %{}) do
    attrs = attributes(:user, attrs)
    {:ok, %{user: user}} = Accounts.register_user(attrs)
    user
  end


  alias MoodleNet.OAuth

  def oauth_token(%MoodleNet.Accounts.User{id: user_id}) do
    {:ok, token} = OAuth.create_token(user_id)
    token
  end

  def oauth_app(attrs \\ %{}) do
    attrs = attributes(:oauth_app, attrs)
    {:ok, app} =OAuth.create_app(attrs)
  end
end
