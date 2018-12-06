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

  def attributes(:community) do
    %{
      "content" => Faker.Lorem.sentence(),
      "name" => Faker.Pokemon.name(),
      "preferred_username" => Faker.Internet.user_name(),
      "summary" => Faker.Lorem.sentence(),
      "primaryLanguage" => "es",
      "icon" => attributes(:image)
    }
  end

  def attributes(:collection) do
    %{
      "content" => Faker.Lorem.sentence(),
      "name" => Faker.Beer.brand(),
      "icon" => attributes(:image)
    }
  end

  def attributes(:resource) do
    %{
      "content" => Faker.Lorem.sentence(),
      "name" => Faker.Industry.industry(),
      "url" => Faker.Internet.url(),
      "summary" => Faker.Lorem.sentence(),
      "icon" => attributes(:image)
    }
  end

  def attributes(:comment) do
    %{
      "content" => Faker.Lorem.sentence(),
      "primary_language" => "fr",
    }
  end

  def attributes(:image) do
    img_id = Faker.random_between(1, 1000)
    %{
      "type" => "Image",
      "url" => "https://picsum.photos/405/275=#{img_id}",
      "width" => 405,
      "height" => 275
    }
  end

  def attributes(:icon) do
    %{
      "type" => "Image",
      "url" => Faker.Avatar.image_url(300, 300),
      "width" => 300,
      "height" => 300
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

  def user(attrs \\ %{}) do
    attrs = attributes(:user, attrs)
    {:ok, %{user: user}} = Accounts.register_user(attrs)
    user
  end

  def actor(attrs \\ %{}) do
    user = user(attrs)
    ActivityPub.get_by_local_id(user.primary_actor_id)
  end


  alias MoodleNet.OAuth

  def oauth_token(%MoodleNet.Accounts.User{id: user_id}) do
    {:ok, token} = OAuth.create_token(user_id)
    token
  end

  def oauth_app(attrs \\ %{}) do
    attrs = attributes(:oauth_app, attrs)
    {:ok, app} = OAuth.create_app(attrs)
    app
  end

  def community(attrs \\ %{}) do
    attrs = attributes(:community, attrs)
    {:ok, c} = MoodleNet.create_community(attrs)
    c
  end

  def collection(community, attrs \\ %{}) do
    attrs = attributes(:collection, attrs)
    {:ok, c} = MoodleNet.create_collection(community, attrs)
    c
  end

  def resource(context, attrs \\ %{}) do
    attrs = attributes(:resource, attrs)
    {:ok, c} = MoodleNet.create_resource(context, attrs)
    c
  end

  def comment(author, context, attrs \\ %{}) do
    attrs = attributes(:comment, attrs)
    {:ok, c} = MoodleNet.create_thread(author, context, attrs)
    c
  end

  def reply(author, in_reply_to, attrs \\ %{}) do
    attrs = attributes(:comment, attrs)
    {:ok, c} = MoodleNet.create_reply(author, in_reply_to, attrs)
    c
  end
end
