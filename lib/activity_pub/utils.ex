defmodule ActivityPub.Utils do
  @moduledoc """
  Misc functions used for federation
  """
  alias ActivityPub.Keys
  alias ActivityPub.Object

  defp get_ap_id(%{"id" => id} = _), do: id
  defp get_ap_id(id), do: id

  @doc """
  Some implementations send the actor URI as the actor field, others send the entire actor object,
  this function figures out what the actor's URI is based on what we have.
  """
  def normalize_params(params) do
    Map.put(params, "actor", get_ap_id(params["actor"]))
  end


  @doc """
  Checks if an actor struct has a non-nil keys field and generates a PEM if it doesn't.
  TODO: Maybe move to Actor module and store keys in AP Actor table? (also TODO)
  """
  def ensure_keys_present(actor) do
    if actor.keys do
      {:ok, actor}
    else
      {:ok, pem} = Keys.generate_rsa_pem()

      ActivityPub.update(actor, %{keys: pem})
    end
  end

  @doc """
  Inserts a full object if it is contained in an activity.
  """
  def insert_full_object(%{"object" => object_data} = map)
      when is_map(object_data) do
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
      |> Map.put(:data, normalize_params(data))
      |> Map.put(:local, false)
      |> Map.put(:public, public?(data))

    {:ok, data}
  end
end
