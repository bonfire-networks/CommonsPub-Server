defmodule MoodleNetWeb.Helpers.Communities do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.{
    CommonResolver,
    UsersResolver,
    CommunitiesResolver
  }

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.Profiles

  def community_load(_socket, page_params, preload) do
    # IO.inspect(socket)

    username = e(page_params, "username", nil)

    {:ok, community} =
      if(!is_nil(username)) do
        CommunitiesResolver.community(%{username: username}, %{})
      else
        {:ok, %{}}
      end
      IO.inspect(preload, label: "sidaisd")

    Profiles.prepare(community, preload, 150)
  end

  def user_communities(for_user, current_user) do
    user_communities(for_user, current_user, 10)
  end

  def user_communities(for_user, current_user, limit) do
    communities_from_edges(user_communities_follows(for_user, current_user, limit))
  end

  def user_communities_follows(for_user, current_user) do
    user_communities_follows(for_user, current_user, 5)
  end

  def user_communities_follows(for_user, current_user, limit) do
    user_communities_follows(for_user, current_user, limit, [])
  end

  def user_communities_follows(for_user, current_user, limit, page_after) do
    {:ok, communities} =
      UsersResolver.community_follows_edge(
        for_user,
        %{limit: limit, after: page_after},
        %{context: %{current_user: current_user}}
      )

    # IO.inspect(my_follows: communities)

    communities
  end

  def communities_from_edges(communities) do
    # FIXME: communities should be joined to edges rather than queried seperately
    communities =
      Enum.map(
        communities.edges,
        &CommonResolver.context_edge(&1, nil, nil)
      )

    communities =
      Enum.map(
        communities,
        &Profiles.prepare(&1, %{icon: true, image: true, actor: true})
      )

    communities
  end
end
