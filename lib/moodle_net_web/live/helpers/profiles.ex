defmodule MoodleNetWeb.Helpers.Profiles do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.UsersResolver

  alias MoodleNet.GraphQL.{
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePages
  }

  import MoodleNetWeb.Helpers.Common

  def prepare(profile, %{image: _} = preload) do
    profile =
      if(Map.has_key?(profile, "image_url")) do
        profile
      else
        profile
        |> Map.merge(%{image_url: image(profile, :image, "identicon", 700)})
      end

    prepare(
      profile,
      Map.delete(preload, :image)
    )
  end

  def prepare(profile, %{icon: _} = preload) do
    prepare(profile, preload, 50)
  end

  def prepare(profile, %{icon: _} = preload, icon_size) do
    profile =
      if(Map.has_key?(profile, "icon_url")) do
        profile
      else
        profile
        |> Map.merge(%{icon_url: image(profile, :icon, "retro", icon_size)})
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
    user_load(socket, page_params, preload, 50)
  end

  def user_load(socket, page_params, preload, icon_width) do
    # IO.inspect(socket)

    username = e(page_params, "username", nil)

    # load requested user
    {:ok, user} =
      if(!is_nil(username)) do
        UsersResolver.user(%{username: username}, %{
          context: %{current_user: socket.assigns.current_user}
        })
      else
        # fallback to current user
        if(Map.has_key?(socket, :assigns) and Map.has_key?(socket.assigns, :current_user)) do
          {:ok, socket.assigns.current_user}
        else
          {:ok, %{}}
        end
      end

    prepare(user, preload, icon_width)
  end
end
