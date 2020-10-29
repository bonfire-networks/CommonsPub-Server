# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.GraphQL do
  # default to 100 km radius
  @radius_default_distance 100_000

  # alias CommonsPub.Web.GraphQL.{CommonResolver}
  require Logger


  alias CommonsPub.{
    # Activities,
    # Communities,
    GraphQL,
    Repo
    # User
  }

  alias CommonsPub.GraphQL.{
    ResolveField,
    # ResolveFields,
    # ResolvePage,
    # ResolvePages,
    ResolveRootPage,
    FetchPage
    # FetchPages,
    # CommonResolver
  }

  # alias CommonsPub.Resources.Resource
  # alias CommonsPub.Common.Enums
  alias CommonsPub.Meta.Pointers
  # alias CommonsPub.Communities.Community
  # alias CommonsPub.Web.GraphQL.CommunitiesResolver

  # alias ValueFlows.Proposal
  alias ValueFlows.Proposal.Proposals
  # alias ValueFlows.Proposal.Queries
  # alias CommonsPub.Web.GraphQL.CommonResolver

  # use Absinthe.Schema.Notation
  # import_sdl path: "lib/value_flows/graphql/schemas/proposal.gql"

  ## resolvers

  def proposal(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_proposal,
      context: id,
      info: info
    })
  end

  def proposals(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_proposals,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def all_proposals(_page_opts, _info) do
    Proposals.many()
  end

  def eligible_location_edge(%{eligible_location_id: id} = proposal, _, _) when not is_nil(id) do
    proposal = Repo.preload(proposal, :eligible_location)

    location =
      proposal
      |> Map.get(:eligible_location, nil)
      |> Geolocation.Geolocations.populate_coordinates()

    {:ok, location}
  end

  def eligible_location_edge(_, _, _), do: {:ok, nil}

  ## fetchers

  def fetch_proposal(info, id) do
    Proposals.one([
      :default,
      user: GraphQL.current_user(info),
      id: id
      # preload: :tags
    ])
  end

  def fetch_proposals(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: ValueFlows.Proposal.Queries,
      query: ValueFlows.Proposal,
      page_opts: page_opts,
      base_filters: [
        :default,
        # preload: [:provider, :receiver, :tags],
        user: GraphQL.current_user(info)
      ]
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end

  def proposals_filtered(page_opts, _ \\ nil) do
    # IO.inspect(proposals_filtered: page_opts)
    proposals_filter(page_opts, [])
  end

  # def proposals_filtered(page_opts, _) do
  #   IO.inspect(unhandled_filtering: page_opts)
  #   all_proposals(page_opts, nil)
  # end

  # TODO: support several filters combined, plus pagination on filtered queries

  defp proposals_filter(%{agent: id} = page_opts, filters_acc) do
    proposals_filter_next(:agent, [agent_id: id], page_opts, filters_acc)
  end

  defp proposals_filter(%{in_scope_of: context_id} = page_opts, filters_acc) do
    proposals_filter_next(:in_scope_of, [context_id: context_id], page_opts, filters_acc)
  end

  defp proposals_filter(%{at_location: at_location_id} = page_opts, filters_acc) do
    proposals_filter_next(
      :at_location,
      [eligible_location_id: at_location_id],
      page_opts,
      filters_acc
    )
  end

  defp proposals_filter(
         %{
           geolocation: %{
             near_point: %{lat: lat, long: long},
             distance: %{meters: distance_meters}
           }
         } = page_opts,
         filters_acc
       ) do
    # IO.inspect(geo_with_point: page_opts)

    proposals_filter_next(
      :geolocation,
      {
        :near_point,
        %Geo.Point{coordinates: {lat, long}, srid: 4326},
        :distance_meters,
        distance_meters
      },
      page_opts,
      filters_acc
    )
  end

  defp proposals_filter(
         %{
           geolocation: %{near_address: address} = geolocation
         } = page_opts,
         filters_acc
       ) do
    # IO.inspect(geo_with_address: page_opts)

    with {:ok, coords} <- Geocoder.call(address) do
      # IO.inspect(coords)

      proposals_filter(
        Map.merge(
          page_opts,
          %{
            geolocation:
              Map.merge(geolocation, %{
                near_point: %{lat: coords.lat, long: coords.lon},
                distance: Map.get(geolocation, :distance, %{meters: @radius_default_distance})
              })
          }
        ),
        filters_acc
      )
    else
      _ ->
        proposals_filter_next(
          :geolocation,
          [],
          page_opts,
          filters_acc
        )
    end
  end

  defp proposals_filter(
         %{
           geolocation: geolocation
         } = page_opts,
         filters_acc
       ) do
    # IO.inspect(geo_without_distance: page_opts)

    proposals_filter(
      Map.merge(
        page_opts,
        %{
          geolocation:
            Map.merge(geolocation, %{
              # default to 100 km radius
              distance: %{meters: @radius_default_distance}
            })
        }
      ),
      filters_acc
    )
  end

  defp proposals_filter(
         _,
         filters_acc
       ) do
    # IO.inspect(filters_query: filters_acc)

    # finally, if there's no more known params to acumulate, query with the filters
    Proposals.many(filters_acc)
  end

  defp proposals_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when is_list(param_remove) and is_list(filter_add) do
    # IO.inspect(proposals_filter_next: param_remove)
    # IO.inspect(proposals_filter_add: filter_add)

    proposals_filter(Map.drop(page_opts, param_remove), filters_acc ++ filter_add)
  end

  defp proposals_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(filter_add) do
    proposals_filter_next(param_remove, [filter_add], page_opts, filters_acc)
  end

  defp proposals_filter_next(param_remove, filter_add, page_opts, filters_acc)
       when not is_list(param_remove) do
    proposals_filter_next([param_remove], filter_add, page_opts, filters_acc)
  end

  def create_proposal(%{proposal: %{in_scope_of: context_ids} = attrs}, info)
      when is_list(context_ids) do
    # FIXME: support multiple contexts?
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_create(attrs, info, fn user, attrs ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Proposals.create(user, context, attrs)
        end
      end)
    end)
  end

  # FIXME: duplication!
  def create_proposal(%{proposal: attrs}, info) do
    Repo.transact_with(fn ->
      do_create(attrs, info, &Proposals.create/2)
    end)
  end

  defp do_create(%{} = attrs, info, create_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         proposal_attrs = Map.merge(attrs, %{is_public: true}),
         {:ok, proposal} <- create_fn.(user, proposal_attrs) do
      {:ok, %{proposal: proposal}}
    end
  end

  def update_proposal(%{proposal: %{in_scope_of: context_ids} = changes}, info) do
    context_id = List.first(context_ids)

    Repo.transact_with(fn ->
      do_update(changes, info, fn proposal, changes ->
        with {:ok, pointer} <- Pointers.one(id: context_id) do
          context = Pointers.follow!(pointer)
          Proposals.update(proposal, context, changes)
        end
      end)
    end)
  end

  def update_proposal(%{proposal: changes}, info) do
    Repo.transact_with(fn ->
      do_update(changes, info, fn proposal, changes ->
        Proposals.update(proposal, changes)
      end)
    end)
  end

  defp do_update(%{id: id} = changes, info, update_fn) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, proposal} <- proposal(%{id: id}, info),
         :ok <- ensure_update_permission(user, proposal),
         {:ok, proposal} <- update_fn.(proposal, changes) do
      {:ok, %{proposal: proposal}}
    end
  end

  def delete_proposal(%{id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, proposal} <- proposal(%{id: id}, info),
           :ok <- ensure_update_permission(user, proposal),
           {:ok, _} <- Proposals.soft_delete(proposal) do
        {:ok, true}
      end
    end)
  end

  def ensure_update_permission(user, proposal) do
    if user.local_user.is_instance_admin or proposal.creator_id == user.id do
      :ok
    else
      GraphQL.not_permitted("update")
    end
  end

  # defp validate_agent(pointer) do
  #   if Pointers.table!(pointer).schema in valid_contexts() do
  #     :ok
  #   else
  #     GraphQL.not_permitted()
  #   end
  # end

  # defp valid_contexts() do
  #   [User, Community, Organisation]
  #   # Keyword.fetch!(CommonsPub.Config.get(Threads), :valid_contexts)
  # end
end
