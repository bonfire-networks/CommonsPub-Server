defmodule MoodleNetWeb.Helpers.Communities do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  alias MoodleNet.GraphQL.{
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePages
  }

  import MoodleNetWeb.Helpers.Common

  def prepare(community, %{image: _} = preload) do
    community =
      if(Map.has_key?(community, "image_url")) do
        community
      else
        community
        |> Map.merge(%{image_url: image(community, :image)})
      end

    prepare(
      community,
      Map.delete(preload, :image)
    )
  end

  def prepare(community, %{icon: _} = preload) do
    community =
      if(Map.has_key?(community, "icon_url")) do
        community
      else
        community
        |> Map.merge(%{icon_url: image(community, :icon)})
      end

    prepare(
      community,
      Map.delete(preload, :icon)
    )
  end

  def prepare(community, preload) do
    community =
      if(Map.has_key?(community, :__struct__)) do
        Enum.reduce(preload, community, fn field, community ->
          {preload, included} = field

          if(included) do
            Map.merge(community, Repo.preload(community, preload))
          else
            community
          end
        end)
      else
        community
      end

    prepare(community)
  end

  def prepare(community) do
    prepare_website(community)
  end

  def prepare_website(community) do
    if(Map.has_key?(community, :website) and !is_nil(community.website)) do
      url = MoodleNet.File.ensure_valid_url(community.website)

      # IO.inspect(url)

      community
      |> Map.merge(%{website: url |> URI.to_string(), website_friendly: url.host})
    else
      community
    end
  end

  def community_load(socket, page_params, preload) do
    # IO.inspect(socket)

    username = e(page_params, "username", nil)

    {:ok, community} =
      if(!is_nil(username)) do
        CommunitiesResolver.community(%{username: username}, %{})
      else
        {:ok, %{}}
      end
    prepare(community, preload)
  end

  def image(community, field_name) do
    if(Map.has_key?(community, :__struct__)) do
      community = Repo.preload(community, field_name)
      icon = Repo.preload(Map.get(community, field_name), :content_upload)

      if(!is_nil(e(icon, :content_upload, :url, nil))) do
        # use uploaded image
        icon.content_upload.url
      else
        # otherwise external image
        icon = Repo.preload(Map.get(community, field_name), :content_mirror)

        if(!is_nil(e(icon, :content_mirror, :url, nil))) do
          icon.content_mirror.url
        else
          # or gravatar
          # TODO: replace with email
          MoodleNet.Users.Gravatar.url(community.id)
        end
      end
    else
      MoodleNet.Users.Gravatar.url("default")
    end
  end
end
