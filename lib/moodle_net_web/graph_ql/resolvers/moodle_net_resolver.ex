defmodule MoodleNetWeb.GraphQL.Resolvers.MoodleNetResolver do
  def list_communities(_field_arguments, _resolution_struct) do
    comms =
      MoodleNet.list_communities()
      |> Enum.map(&prepare_comm/1)

    {:ok, comms}
  end

  def get_community(%{local_id: local_id}, _) do
    comm = MoodleNet.get_entity_by_id(local_id)

    if comm && "MoodleNet:Community" in comm[:type] do
      {:ok, prepare_comm(comm)}
    else
      {:ok, nil}
    end
  end

  defp prepare_comm(comm) do
    {:ok, collections} = list_collections(%{context: comm[:local_id]}, %{})
    {:ok, comments} = list_comments(%{context: comm[:local_id]}, %{})

    comm
    |> ActivityPub.SQL.preload([:icon, :context])
    |> to_map()
    |> Map.put(:collections, collections)
    |> Map.put(:comments, comments)
  end

  def list_collections(%{context: context_local_id}, _) do
    cols =
      MoodleNet.list_collections(context_local_id)
      |> Enum.map(&prepare_col/1)

    {:ok, cols}
  end

  def get_collection(%{local_id: local_id}, _) do
    col = MoodleNet.get_entity_by_id(local_id)

    if col && "MoodleNet:Collection" in col[:type] do
      {:ok, prepare_col(col)}
    else
      {:ok, nil}
    end
  end

  defp prepare_col(col) do
    {:ok, resources} = list_resources(%{context: col[:local_id]}, %{})
    {:ok, comments} = list_comments(%{context: col[:local_id]}, %{})

    col
    |> ActivityPub.SQL.preload([:icon, :context])
    |> to_map()
    |> Map.put(:resources, resources)
    |> Map.put(:comments, comments)
  end

  def list_resources(%{context: context_local_id}, _) do
    resources =
      MoodleNet.list_resources(context_local_id)
      |> Enum.map(&prepare_resource/1)

    {:ok, resources}
  end

  def get_resource(%{local_id: local_id}, _) do
    res = MoodleNet.get_entity_by_id(local_id)

    if res && "MoodleNet:EducationalResource" in res[:type] do
      {:ok, prepare_resource(res)}
    else
      {:ok, nil}
    end
  end

  defp prepare_resource(resource) do
    resource
    |> ActivityPub.SQL.preload(:context)
    |> to_map()
  end

  def list_comments(args, _) do
    comments =
      MoodleNet.list_comments(args)
      |> Enum.map(fn comment ->
        # comments = list_comments(comment[:local_id])

        comment
        |> ActivityPub.SQL.preload([:attributed_to])
        |> to_map()

        # |> Map.put(:comments, comments)
      end)

    {:ok, comments}
  end

  # def list_resources(context_local_id) do
  #   MoodleNet.list_collections(context_local_id) |> Enum.map(&to_map/1)
  # end

  def to_map(comm) do
    %{
      id: comm[:id],
      local_id: comm[:local_id],
      local: comm[:local],
      type: comm[:type],
      name: from_language_value(comm[:name]),
      content: from_language_value(comm[:content]),
      summary: from_language_value(comm[:summary]),
      preferred_username: comm[:preferred_username],
      following_count: comm[:following_count],
      followers_count: comm[:followers_count],
      json_data: comm.extension_fields,
      icon: to_icon(comm[:icon]),
      primary_language: comm[:primary_language],
      location: comm[:location],
      email: comm[:email],
      url: comm[:url] |> List.first(),
      collections_count: 10,
      resources_count: 5,
      likes_count: 12,
      comments: comm[:comments],
      author: (comm[:attributed_to] || []) |> List.first(),
      context: (comm[:context] || []) |> List.first(),
    }
  end

  def from_language_value(string) when is_binary(string), do: string
  def from_language_value(%{"und" => value}), do: value
  def from_language_value(%{}), do: nil

  def to_icon([entity | _]) do
    with [url | _] <- entity[:url] do
      url
    else
      _ -> nil
    end
  end

  def to_icon(_), do: nil
end
