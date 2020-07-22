defmodule MoodleNetWeb.Helpers.Communities do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.{
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

    Profiles.prepare(community, preload, 150)
  end

  def user_communities(for_user, current_user) do
    user_communities(for_user, current_user, 10)
  end

  def user_communities(for_user, current_user, limit) do
    user_communities(for_user, current_user, limit, [])
  end

  def user_communities(for_user, current_user, limit, page_after) do
    communities_from_follows(user_communities_follows(for_user, current_user, limit, page_after))
  end

  def user_communities_follows(for_user, current_user) do
    user_communities_follows(for_user, current_user, 5)
  end

  def user_communities_follows(for_user, current_user, limit) do
    user_communities_follows(for_user, current_user, limit, [])
  end

  def user_communities_follows(for_user, current_user, limit, page_after) do
    {:ok, follows} =
      UsersResolver.community_follows_edge(
        for_user,
        %{limit: limit, after: page_after},
        %{context: %{current_user: current_user}}
      )

    # IO.inspect(my_follows: follows)

    follows
  end

  def communities_from_follows(%{edges: edges}) when length(edges) > 0 do
    # FIXME: communities should be joined to edges rather than queried seperately

    IO.inspect(communities_from_follows: edges)
    ids = Enum.map(edges, & &1.context_id)
    IO.inspect(ids: ids)

    communities = contexts_fetch!(ids)
    IO.inspect(communities: communities)

    communities =
      if(communities) do
        Enum.map(
          communities,
          &Profiles.prepare(&1, %{icon: true, image: true, actor: true})
        )
      end

    communities
  end

  def communities_from_follows(_) do
    []
  end
end
