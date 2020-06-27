defmodule MoodleNetWeb.Helpers.Profiles do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.UsersResolver

  import MoodleNetWeb.Helpers.Common

  def prepare(profile, %{image: _} = preload) do
    profile =
      if(Map.has_key?(profile, "image_url")) do
        profile
      else
        profile
        |> Map.merge(%{image_url: image(profile, :image)})
      end

    prepare(
      profile,
      Map.delete(preload, :image)
    )
  end

  def prepare(profile, %{icon: _} = preload) do
    profile =
      if(Map.has_key?(profile, "icon_url")) do
        profile
      else
        profile
        |> Map.merge(%{icon_url: image(profile, :icon)})
      end

    prepare(
      profile,
      Map.delete(preload, :icon)
    )
  end

  def prepare(profile, preload) do
    profile =
      if(Map.has_key?(profile, :__struct__)) do
        Enum.reduce(preload, profile, fn field, profile ->
          {preload, included} = field

          if(included) do
            Map.merge(profile, Repo.preload(profile, preload))
          else
            profile
          end
        end)
      else
        profile
      end

    prepare(profile)
  end

  def prepare(profile) do
    prepare_website(profile)
  end

  def prepare_website(profile) do
    if(Map.has_key?(profile, :website) and !is_nil(profile.website)) do
      url = MoodleNet.File.ensure_valid_url(profile.website)

      # IO.inspect(url)

      profile
      |> Map.merge(%{website: url |> URI.to_string(), website_friendly: url.host})
    else
      profile
    end
  end

  def user_load(socket, page_params, preload) do
    IO.inspect(socket)

    # TODO: use logged in user here
    username = e(page_params, "username", nil)

    {:ok, user} =
      if(!is_nil(username)) do
        UsersResolver.user(%{username: username}, nil)
      else
        if(Map.has_key?(socket, :assigns) and Map.has_key?(socket.assigns, :current_user)) do
          {:ok, socket.assigns.current_user}
        else
          {:ok, %{}}
        end
      end

    prepare(user, preload)
  end

  def image(profile, field_name) do
    if(Map.has_key?(profile, :__struct__)) do
      profile = Repo.preload(profile, field_name)
      icon = Repo.preload(Map.get(profile, field_name), :content_upload)

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
    else
      MoodleNet.Users.Gravatar.url("default")
    end
  end
end
