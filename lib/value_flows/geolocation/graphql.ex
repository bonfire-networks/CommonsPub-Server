# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Geolocation.GraphQL do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_sdl path: "lib/value_flows/graphql/schemas/geolocation.gql"

  alias MoodleNet.{
    Activities,
    Communities,
    GraphQL,
    Repo,
  }
  alias MoodleNet.GraphQL.{Flow, FieldsFlow, PageFlow, PagesFlow}
  alias MoodleNet.Common.Enums
  alias MoodleNetWeb.GraphQL.CommunitiesResolver
  alias ValueFlows.Geolocation
  alias ValueFlows.Geolocations
  alias ValueFlows.Geolocations.Queries

  ## resolvers

  def geolocation(%{geolocation_id: id}, info) do
    Flow.field(__MODULE__, :fetch_geolocation, id, info)
  end

  def geolocations(page_opts, info) do
    vals = [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1] # popularity
    opts = %{default_limit: 10}
    ret = Flow.root_page(__MODULE__, :fetch_geolocations, page_opts, info, vals, opts)
    ret
  end

  ## fetchers

  def fetch_geolocation(info, id) do
    user = GraphQL.current_user(info)
    Geolocations.one(
      user: user,
      id: id,
      preload: :actor
    )
  end

  def fetch_geolocations(page_opts, info) do
    user = GraphQL.current_user(info)
    PageFlow.run(
      %PageFlow{
        queries: Geolocations.Queries,
        query: Geolocation,
        cursor_fn: Geolocations.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: user],
        data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end


  def community_edge(%Geolocation{community_id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_community_edge, id, info
  end

  def fetch_community_edge(_, ids) do
    {:ok, fields} = Communities.fields(&(&1.id), [:default, id: ids])
    fields
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%Geolocation{outbox_id: id}, page_opts, info) do
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
    Application.fetch_env!(:moodle_net, Geolocations)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  ## finally the mutations...

  def create_geolocation(%{geolocation: attrs, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, community} <- CommunitiesResolver.community(%{community_id: id}, info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Geolocations.create(user, community, attrs)
      end
    end)
  end

  def update_geolocation(%{geolocation: changes, geolocation_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, geolocation} <- geolocation(%{geolocation_id: id}, info) do
        geolocation = Repo.preload(geolocation, :community)
        cond do
          user.local_user.is_instance_admin ->
	    Geolocations.update(geolocation, changes)

          geolocation.creator_id == user.id ->
	    Geolocations.update(geolocation, changes)

          geolocation.community.creator_id == user.id ->
	    Geolocations.update(geolocation, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end

end
