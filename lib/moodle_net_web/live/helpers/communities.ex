defmodule MoodleNetWeb.Helpers.Communities do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.{
    CommonResolver,
    UsersResolver,
    CommunitiesResolver
  }

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
        |> Map.merge(%{image_url: image(community, :image, "identicon", 700)})
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
    prepare_website(prepare_username(community))
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

  def user_communities(for_user, current_user) do
    {:ok, communities} =
      UsersResolver.community_follows_edge(
        for_user,
        %{limit: 10},
        %{context: %{current_user: current_user}}
      )

    # IO.inspect(my_follows: communities)

    # FIXME: communities should be joined rather than queried one by one
    communities =
      Enum.map(
        communities.edges,
        &CommonResolver.context_edge(&1, nil, nil)
      )

    communities =
      Enum.map(
        communities,
        &prepare(&1, %{icon: true, image: true, actor: true})
      )

    # IO.inspect(communities)
  end
end
