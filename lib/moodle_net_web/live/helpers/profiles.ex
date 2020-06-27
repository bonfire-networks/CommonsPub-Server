defmodule MoodleNetWeb.Helpers.Profiles do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.UsersResolver

  import MoodleNetWeb.Helpers.Common

  def prepare(profile, %{image: _}) do
    profile = prepare(profile)

    image = image(profile, :image)

    profile
    |> Map.merge(%{image: image})
  end

  def prepare(profile) do
    profile = Repo.preload(profile, :actor)

    icon = image(profile, :icon)

    profile
    |> Map.merge(%{icon: icon})
  end

  def user_load(page_params, preload) do
    IO.inspect(page_params)

    # TODO: use logged in user here
    username = e(page_params, "username", "mayel")
    IO.inspect(username)

    {:ok, user} = UsersResolver.user(%{username: username}, nil)
    user = prepare(user, preload)
  end

  def image(profile, field_name) do
    profile = Repo.preload(profile, field_name)
    icon = Repo.preload(Map.get(profile, field_name), :content_upload)

    icon =
      if(!is_nil(e(icon, :content_upload, :url, nil))) do
        # use uploaded image
        icon.content_upload.url
      else
        # otherwise external image
        icon = Repo.preload(Map.get(profile, field_name), :content_mirror)

        if(!is_nil(e(icon, :content_mirror, :url, nil))) do
          icon.content_mirror.url
        else
          # or gravatar
          # TODO: replace with email
          MoodleNet.Users.Gravatar.url(profile.id)
        end
      end
  end
end
