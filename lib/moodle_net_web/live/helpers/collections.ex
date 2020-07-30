defmodule MoodleNetWeb.Helpers.Collections do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.{
    UsersResolver,
    CollectionsResolver
  }

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.Profiles

  def collection_load(_socket, page_params, preload) do
    # IO.inspect(socket)

    username = e(page_params, "username", nil)

    {:ok, collection} =
      if(!is_nil(username)) do
        CollectionsResolver.collection(%{username: username}, %{})
      else
        {:ok, %{}}
      end

    Profiles.prepare(collection, preload, 150)
  end

  def user_collections(for_user, current_user) do
    user_collections(for_user, current_user, 10)
  end

  def user_collections(for_user, current_user, limit) do
    user_collections(for_user, current_user, limit, [])
  end

  def user_collections(for_user, current_user, limit, page_after) do
    collections_from_follows(user_collections_follows(for_user, current_user, limit, page_after))
  end

  def user_collections_follows(for_user, current_user) do
    user_collections_follows(for_user, current_user, 5)
  end

  def user_collections_follows(for_user, current_user, limit) do
    user_collections_follows(for_user, current_user, limit, [])
  end

  def user_collections_follows(for_user, current_user, limit, page_after) do
    {:ok, follows} =
      UsersResolver.collection_follows_edge(
        for_user,
        %{limit: limit, after: page_after},
        %{context: %{current_user: current_user}}
      )

    # IO.inspect(my_follows: follows)

    follows
  end

  def collections_from_follows(%{edges: edges}) when length(edges) > 0 do
    # FIXME: collections should be joined to edges rather than queried seperately

    # IO.inspect(collections_from_follows: edges)
    ids = Enum.map(edges, & &1.context_id)

    # IO.inspect(ids: ids)

    collections = contexts_fetch!(ids)

    # IO.inspect(collections: collections)

    collections =
      if(collections) do
        Enum.map(
          collections,
          &Profiles.prepare(&1, %{icon: true, image: true, actor: true})
        )
      end

    collections
  end

  def collections_from_follows(_) do
    []
  end
end
