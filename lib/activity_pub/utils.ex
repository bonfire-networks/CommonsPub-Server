defmodule ActivityPub.Utils do
  @moduledoc """
  Misc functions used for federation
  """
  alias ActivityPub.Actor
  alias ActivityPub.Keys
  alias ActivityPub.Object
  alias Ecto.UUID
  alias MoodleNet.Repo

  import Ecto.Query

  @public_uri "https://www.w3.org/ns/activitystreams#Public"
  @supported_object_types ["Article", "Note", "Video", "Page", "Question", "Answer"]

  def get_ap_id(%{"id" => id} = _), do: id
  def get_ap_id(id), do: id

  @doc """
  Some implementations send the actor URI as the actor field, others send the entire actor object,
  this function figures out what the actor's URI is based on what we have.
  """
  def normalize_params(params) do
    Map.put(params, "actor", get_ap_id(params["actor"]))
  end

  defp make_date do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  def generate_context_id do
    generate_id("contexts")
  end

  def generate_object_id do
    generate_id("objects")
  end

  def generate_id(type) do
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

    "#{MoodleNetWeb.base_url()}#{ap_base_path}/#{type}/#{UUID.generate()}"
  end

  def make_json_ld_header do
    %{
      "@context" => [
        "https://www.w3.org/ns/activitystreams",
        %{
          "@language" => "und"
        }
      ]
    }
  end

  #### Follow-related helpers
  def make_follow_data(
        %{data: %{"id" => follower_id}},
        %{data: %{"id" => followed_id}} = _followed,
        activity_id
      ) do
    data = %{
      "type" => "Follow",
      "actor" => follower_id,
      "to" => [followed_id],
      "cc" => [@public_uri],
      "object" => followed_id,
      "state" => "pending"
    }

    data = if activity_id, do: Map.put(data, "id", activity_id), else: data

    data
  end

  def fetch_latest_follow(%{data: %{"id" => follower_id}}, %{data: %{"id" => followed_id}}) do
    query =
      from(
        activity in Object,
        where:
          fragment(
            "? ->> 'type' = 'Follow'",
            activity.data
          ),
        where:
          fragment(
            "? ->> 'actor' = ?",
            activity.data,
            ^follower_id
          ),
        where:
          fragment(
            "coalesce((?)->'object'->>'id', (?)->>'object') = ?",
            activity.data,
            activity.data,
            ^followed_id
          ),
        order_by: [fragment("? desc nulls last", activity.inserted_at)],
        limit: 1
      )

    Repo.one(query)
  end

  def make_unfollow_data(follower, followed, follow_activity, activity_id) do
    data = %{
      "type" => "Undo",
      "actor" => follower.data["id"],
      "to" => [followed.data["id"]],
      "object" => follow_activity.data
    }

    if activity_id, do: Map.put(data, "id", activity_id), else: data
  end

  #### Block-related helpers
  def fetch_latest_block(%{data: %{"id" => blocker_id}}, %{data: %{"id" => blocked_id}}) do
    query =
      from(
        activity in Object,
        where:
          fragment(
            "? ->> 'type' = 'Block'",
            activity.data
          ),
        where:
          fragment(
            "? ->> 'actor' = ?",
            activity.data,
            ^blocker_id
          ),
        where:
          fragment(
            "coalesce((?)->'object'->>'id', (?)->>'object') = ?",
            activity.data,
            activity.data,
            ^blocked_id
          ),
        order_by: [fragment("? desc nulls last", activity.inserted_at)],
        limit: 1
      )

    Repo.one(query)
  end

  def make_block_data(blocker, blocked, activity_id) do
    data = %{
      "type" => "Block",
      "actor" => blocker.data["id"],
      "to" => [blocked.data["id"]],
      "object" => blocked.data["id"]
    }

    if activity_id, do: Map.put(data, "id", activity_id), else: data
  end

  def make_unblock_data(blocker, blocked, block_activity, activity_id) do
    data = %{
      "type" => "Undo",
      "actor" => blocker.data["id"],
      "to" => [blocked.data["id"]],
      "object" => block_activity.data
    }

    if activity_id, do: Map.put(data, "id", activity_id), else: data
  end

  #### Create-related helpers
  def make_create_data(params, additional) do
    published = params.published || make_date()

    %{
      "type" => "Create",
      "to" => params.to |> Enum.uniq(),
      "actor" => params.actor.data["id"],
      "object" => params.object,
      "published" => published,
      "context" => params.context
    }
    |> Map.merge(additional)
  end

  @doc """
  Checks if an actor struct has a non-nil keys field and generates a PEM if it doesn't.
  """
  def ensure_keys_present(actor) do
    if actor.keys do
      {:ok, actor}
    else
      # TODO: move MN specific calls elsewhere
      {:ok, pem} = Keys.generate_rsa_pem()
      {:ok, local_actor} = MoodleNet.Actors.fetch_by_username(actor.data["preferredUsername"])
      {:ok, local_actor} = MoodleNet.Actors.update(local_actor, %{signing_key: pem})
      actor = Actor.format_local_actor(local_actor)
      {:ok, actor}
    end
  end

  @doc """
  Inserts a full object if it is contained in an activity.
  """
  def insert_full_object(%{"object" => %{"type" => type} = object_data} = map)
      when is_map(object_data) and type in @supported_object_types do
    with {:ok, data} <- prepare_data(object_data),
         {:ok, object} <- Object.insert(data) do
      map =
        map
        |> Map.put("object", object.data["id"])

      {:ok, map, object}
    end
  end

  def insert_full_object(map), do: {:ok, map, nil}

  @doc """
  Determines if an object or an activity is public.
  """
  def public?(data) do
    recipients = (data["to"] || []) ++ (data["cc"] || [])

    cond do
      recipients == [] ->
        true

      Enum.member?(recipients, "https://www.w3.org/ns/activitystreams#Public") ->
        true

      true ->
        false
    end
  end

  @doc """
  Prepares a struct to be inserted into the objects table
  """
  def prepare_data(data) do
    data =
      %{}
      |> Map.put(:data, data)
      |> Map.put(:local, false)
      |> Map.put(:public, public?(data))

    {:ok, data}
  end

  @doc """
  Enqueues an activity for federation if it's local
  """
  def maybe_federate(%Object{local: true} = activity) do
    if MoodleNet.Config.get!([:instance, :federating]) do
      priority =
        case activity.data["type"] do
          "Delete" -> 10
          "Create" -> 1
          _ -> 5
        end

      ActivityPubWeb.Federator.publish(activity, priority)
    end

    :ok
  end

  def maybe_federate(_), do: :ok

  def lazy_put_activity_defaults(map) do
    context = create_context(map["context"])

    map =
      map
      |> Map.put_new_lazy("id", &generate_object_id/0)
      |> Map.put_new_lazy("published", &make_date/0)
      |> Map.put_new("context", context)

    if is_map(map["object"]) do
      object = lazy_put_object_defaults(map["object"], map)
      %{map | "object" => object}
    else
      map
    end
  end

  def lazy_put_object_defaults(map, activity) do
    map
    |> Map.put_new_lazy("id", &generate_object_id/0)
    |> Map.put_new_lazy("published", &make_date/0)
    |> Map.put_new("context", activity["context"])
  end

  def create_context(context) do
    context || generate_id("contexts")
  end
end
