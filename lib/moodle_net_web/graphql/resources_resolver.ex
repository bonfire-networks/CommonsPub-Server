# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  alias MoodleNet.{Fake, GraphQL, Resources}
  alias MoodleNetWeb.GraphQL.{
    CollectionsResolver,
    CommonResolver,
    LocalisationResolver,
  }

  @todo :for_moot
  def resource(%{resource_id: id}, info) do
    {:ok, Fake.resource()}
    |> GraphQL.response(info)
  end

  @todo :for_moot
  def resources(collection,_, info) do
    {:ok, Fake.med_list(&Fake.resource/0)}
    |> GraphQL.response(info)
  end

  @todo :for_moot
  def create_resource(%{resource: attrs, collection_id: collection_id}, info) do
    # with {:ok, current_user} <- GraphQL.current_user(info) do
    #   Repo.transact_with fn
    #     with {:ok, collection} <- Collection.fetch(collection_id) do
    #       Resources.create(collection, attrs)
    #     end
    #   end
    # end
    {:ok, Fake.resource()}
    |> GraphQL.response(info)
  end

  @todo :for_moot
  def update_resource(%{resource: changes, resource_id: resource_id}, info) do
    # with {:ok, current_user} <- GraphQL.current_user(info) do
    #   Repo.transact_with fn ->
    #     with {:ok, resource} <- Resources.fetch(resource_id) do
    #       resource = Repo.preload(resource, [collection: :community])
    #       permitted? =
    #         current_user.is_instance_admin or
    #         resource.creator_id == current_user.id or
    #         resource.collection.creator_id == current_user.id or
    #         resource.collection.community.creator_id == current_user.id

    #       if permitted?,
    #         do: Resources.update(resource, changes),
    #         else: GraphQL.not_permitted()
    #     end
    #   end
    # end
    {:ok, Fake.resource()}
    |> GraphQL.response(info)
  end

  @todo :for_moot
  def copy_resource(%{resource_id: resource_id, collection_id: collection_id}, info) do
    # with {:ok, current_user} <- GraphQL.current_user(info) do
    #   Repo.transact_with fn ->
    #     with {:ok, collection} <- Collections.fetch(collection_id),
    #          {:ok, resource} <- Resources.fetch(resource_id) do
    #       Resources.copy(resource, collection)
    #     end
    #   end
    # end
    {:ok, Fake.resource()}
    |> GraphQL.response(info)
  end

  @todo :for_moot
  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end

end
