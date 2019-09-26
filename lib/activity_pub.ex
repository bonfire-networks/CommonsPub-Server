# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub do
  @moduledoc """
  ActivityPub API

  In general, the functions in this module take object-like formatted struct as the input for actor parameters.
  Use the functions in the `ActivityPub.Actor` module (`ActivityPub.Actor.get_by_ap_id/1` for example) to retrieve those.

  Legacy: Delegates some functions to related ActivityPub submodules
  """
  alias ActivityPub.Adapter
  alias ActivityPub.Utils
  alias ActivityPub.Object
  alias MoodleNet.Repo

  def insert(map, local) when is_map(map) and is_boolean(local) do
    with map <- Utils.lazy_put_activity_defaults(map),
         {:ok, map, object} <- Utils.insert_full_object(map) do
      {:ok, activity} =
        Repo.insert(%Object{
          data: map,
          local: local,
          public: Utils.public?(map)
        })

      # Splice in the child object if we have one.
      activity =
        if !is_nil(object) do
          Map.put(activity, :object, object)
        else
          activity
        end

      {:ok, activity}
    end
  end

  @doc """
  Generates and federates a Create activity via the data passed through `params`.

  Requires `to`, `actor`, `context` and `object` fields to be present in the input map.

  `to` must be a list.</br>
  `actor` must be an `ActivityPub.Object`-like struct.</br>
  `context` must be a string. Use `ActivityPub.Utils.generate_context_id/0` to generate a default context.</br>
  `object` must be a map.
  """
  def create(%{to: to, actor: actor, context: context, object: object} = params) do
    additional = params[:additional] || %{}
    # only accept false as false value
    local = !(params[:local] == false)
    published = params[:published]

    with create_data <-
           Utils.make_create_data(
             %{to: to, actor: actor, published: published, context: context, object: object},
             additional
           ),
         {:ok, activity} <- insert(create_data, local),
         :ok <- Utils.maybe_federate(activity),
         :ok <- Adapter.maybe_handle_activity(activity) do
      {:ok, activity}
    else
      {:error, message} -> {:error, message}
    end
  end


  @doc """
  Generates and federates an Accept activity via the data passed through `params`.

  Requires 'to', actor' and 'object' fields to be present in the input map.

  `to` must be a list.</br>
  `actor` must be an `ActivityPub.Object`-like struct.</br>
  `object` should be the URI of the object that is being accepted.
  """
  def accept(%{to: to, actor: actor, object: object} = params) do
    # only accept false as false value
    local = !(params[:local] == false)

    with data <- %{"to" => to, "type" => "Accept", "actor" => actor.ap_id, "object" => object},
         {:ok, activity} <- insert(data, local),
         :ok <- Utils.maybe_federate(activity),
         :ok <- Adapter.maybe_handle_activity(activity) do
      {:ok, activity}
    end
  end

  @doc """
  Generates and federates a Reject activity via the data passed through `params`.

  Requires 'to', actor' and 'object' fields to be present in the input map.

  `to` must be a list.<br/>
  `actor` must be an `ActivityPub.Object`-like struct.<br/>
  `object` should be the URI of the object that is being rejected
  """
  def reject(%{to: to, actor: actor, object: object} = params) do
    # only accept false as false value
    local = !(params[:local] == false)

    with data <- %{"to" => to, "type" => "Reject", "actor" => actor.ap_id, "object" => object},
         {:ok, activity} <- insert(data, local),
         :ok <- Utils.maybe_federate(activity),
         :ok <- Adapter.maybe_handle_activity(activity) do
      {:ok, activity}
    end
  end

  @doc """
  Generates and federates a Follow activity.

  Note: the follow should be reflected on the host database side only after receiving an `Accept` activity in response!
  """
  def follow(follower, followed, activity_id \\ nil, local \\ true) do
    with data <- Utils.make_follow_data(follower, followed, activity_id),
         {:ok, activity} <- insert(data, local),
         :ok <- Utils.maybe_federate(activity),
         :ok <- Adapter.maybe_handle_activity(activity) do
      {:ok, activity}
    end
  end

  @doc """
  Generates and federates an Unfollow activity.
  """
  def unfollow(follower, followed, activity_id \\ nil, local \\ true) do
    with %Object{} = follow_activity <- Utils.fetch_latest_follow(follower, followed),
         unfollow_data <-
           Utils.make_unfollow_data(follower, followed, follow_activity, activity_id),
         {:ok, activity} <- insert(unfollow_data, local),
         :ok <- Utils.maybe_federate(activity),
         :ok <- Adapter.maybe_handle_activity(activity) do
      {:ok, activity}
    end
  end

  # Legacy AP API

  @doc """
  Builds an `ActivityPub.Entity`. Delegates to `ActivityPub.Builder.new/1` (see that module for more docs).

  ## Example
  ```
  {:ok, entity} = ActivityPub.new(%{type: "Object", content: "hello world"})
  ```
  """
  defdelegate new(params), to: ActivityPub.Builder

  @doc """
  Delegates to `ActivityPub.Entity.local_id/1`
  """
  defdelegate local_id(entity), to: ActivityPub.Entity

  @doc """
  Delegates to `ActivityPub.ApplyAction.apply/1`
  """
  defdelegate apply(params), to: ActivityPub.ApplyAction

  @doc """
  Delegates to `ActivityPub.SQLEntity.insert/1`
  """
  defdelegate insert(entity), to: ActivityPub.SQLEntity
  defdelegate insert(entity, repo), to: ActivityPub.SQLEntity

  @doc """
  Delegates to `ActivityPub.SQLEntity.update/2`
  """
  defdelegate update(entity, changes), to: ActivityPub.SQLEntity

  @doc """
  Delegates to `ActivityPub.SQLEntity.delete/1`
  """
  defdelegate delete(entity), to: ActivityPub.SQLEntity
  defdelegate delete(entity, assocs), to: ActivityPub.SQLEntity

  @doc """
  Delegates to `ActivityPub.SQL.Query.get_by_local_id/1`
  """
  defdelegate get_by_local_id(params), to: ActivityPub.SQL.Query
  defdelegate get_by_local_id(params, opts), to: ActivityPub.SQL.Query

  @doc """
  Returns an object given an ActivityPub ID. Delegates to `ActivityPub.SQL.Query.get_by_id/1`
  """
  defdelegate get_by_id(params), to: ActivityPub.SQL.Query
  defdelegate get_by_id(params, opts), to: ActivityPub.SQL.Query

  @doc """
  Delegates to `ActivityPub.SQL.Query.reload/1`
  """
  defdelegate reload(params), to: ActivityPub.SQL.Query
end
