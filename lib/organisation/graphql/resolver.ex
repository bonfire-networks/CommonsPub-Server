# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation.GraphQL.Resolver do
  alias MoodleNet.{
    Activities,
    Communities,
    GraphQL,
    Repo,
    Resources,
  }
  alias MoodleNet.GraphQL.{
    Flow,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
  }
  alias Organisation
  alias Organisation.{Organisations, Queries}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  ## resolvers

  def organisation(%{organisation_id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_organisation,
        context: id,
        info: info,
      }
    )
  end

  def organisations(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_organisations,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_organisation(info, id) do
    Organisations.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :actor
    )
  end

  def fetch_organisations(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Organisation.Queries,
        query: Organisation,
        cursor_fn: Organisations.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
        data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end

  def resource_count_edge(%Organisation{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_resource_count_edge, id, info, default: 0
  end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Resources.Queries,
        query: Resource,
        group_fn: &elem(&1, 0),
        map_fn: &elem(&1, 1),
        filters: [organisation_id: ids, group_count: :organisation_id],
      }
    )
  end

  def resources_edge(%Organisation{id: id}, %{}=page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_resources_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_resources_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    FetchPages.run(
      %FetchPages{
        queries: Resources.Queries,
        query: Resource,
        cursor_fn: &[&1.id],
        group_fn: &(&1.organisation_id),
        page_opts: page_opts,
        base_filters: [:deleted, user: user, organisation_id: ids],
        data_filters: [page: [desc: [created: page_opts]]],
        count_filters: [group_count: :organisation_id],
      }
    )
  end

  def fetch_resources_edge(page_opts, info, id) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Resources.Queries,
        query: Resource,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [:deleted, user: user, organisation_id: id],
        data_filters: [page: [desc: [created: page_opts]]],
      }
    )
  end

  def community_edge(%Organisation{community_id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_community_edge, id, info
  end

  def fetch_community_edge(_, ids) do
    {:ok, fields} = Communities.fields(&(&1.id), [:default, id: ids])
    fields
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%Organisation{outbox_id: id}, page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_outbox_edge, page_opts, info, id, info, opts)
  end

  def fetch_outbox_edge({page_opts, info}, id) do
    user = info.context.current_user
    {:ok, box} = Activities.page(
      &(&1.id),
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
    box
  end

  def fetch_outbox_edge(page_opts, info, id) do
    user = info.context.current_user
    Activities.page(
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, Organisations)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  ## finally the mutations...

  def create_organisation(%{organisation: attrs, community_id: id}, info) do 
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, community} <- CommunitiesResolver.community(%{community_id: id}, info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Organisations.create(user, community, attrs)
      end
    end)
  end


  def create_organisation(%{organisation: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Organisations.create(user, attrs)
      end
    end)
  end


  def update_organisation(%{organisation: changes, organisation_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, organisation} <- organisation(%{organisation_id: id}, info) do
        organisation = Repo.preload(organisation, :community)
        cond do
          user.local_user.is_instance_admin ->
	    Organisations.update(organisation, changes)

          organisation.creator_id == user.id ->
	    Organisations.update(organisation, changes)

          organisation.community.creator_id == user.id ->
	    Organisations.update(organisation, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{organisation_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, organisation} <- Organisations.fetch(id) do
  #   #     organisation = Repo.preload(organisation, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       organisation.creator_id == actor.id or
  #   #       organisation.community.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Organisations.soft_delete(organisation), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

end
