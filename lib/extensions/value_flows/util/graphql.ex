# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Util.GraphQL do
  use Absinthe.Schema.Notation

  alias CommonsPub.{
    GraphQL,
    Repo
  }

  require Logger

  # import_sdl path: "lib/value_flows/graphql/schemas/util.gql"

  # object :page_info do
  #   field :start_cursor, list_of(non_null(:cursor))
  #   field :end_cursor, list_of(non_null(:cursor))
  #   field :has_previous_page, non_null(:boolean)
  #   field :has_next_page, non_null(:boolean)
  # end

  def parse_cool_scalar(value), do: {:ok, value}
  def serialize_cool_scalar(%{value: value}), do: value
  def serialize_cool_scalar(value), do: value

  def fetch_provider_edge(%{provider_id: id}, _, info) when not is_nil(id) do
    # CommonResolver.context_edge(%{context_id: id}, nil, info)
    {:ok, ValueFlows.Agent.Agents.agent(id, GraphQL.current_user(info))}
  end

  def fetch_provider_edge(_, _, _) do
    {:ok, nil}
  end

  def fetch_receiver_edge(%{receiver_id: id}, _, info) when not is_nil(id) do
    # CommonResolver.context_edge(%{context_id: id}, nil, info)
    {:ok, ValueFlows.Agent.Agents.agent(id, GraphQL.current_user(info))}
  end

  def fetch_receiver_edge(_, _, _) do
    {:ok, nil}
  end


  def fetch_classifications_edge(%{tags: _tags} = thing, _, _) do
    thing = Repo.preload(thing, tags: :character)
    urls = Enum.map(thing.tags, & &1.character.canonical_url)
    {:ok, urls}
  end

  def current_location_edge(%{current_location_id: id} = thing, _, _) when not is_nil(id) do
    thing = Repo.preload(thing, :current_location)
    {:ok, Geolocation.Geolocations.populate_coordinates(Map.get(thing, :current_location, nil))}
  end

  def at_location_edge(%{at_location_id: id} = thing, _, _) when not is_nil(id) do
    thing = Repo.preload(thing, :at_location)
    {:ok, Geolocation.Geolocations.populate_coordinates(Map.get(thing, :at_location, nil))}
  end

  def at_location_edge(_, _, _) do
    {:ok, nil}
  end
end
