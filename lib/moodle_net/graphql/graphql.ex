defmodule MoodleNet.GraphQL do

  alias Absinthe.Resolution
  alias MoodleNet.Common.{
    NotLoggedInError,
    NotPermittedError,
  }

  defprotocol Response do
    def to_response(self, info, path)
  end

  def response(value_or_tuple, resolution, path \\ [])

  def response({:ok, value}, %Resolution{}=info, path),
    do: {:ok, Response.to_response(value, info, path)}

  def response({:error, value}, %Resolution{}=info, path),
    do: {:error, Response.to_response(value, info, path)}

  def response(value, %Resolution{}=info, path),
    do: Response.to_response(value, info, path)

  def wanted(resolution, path \\ [])

  def wanted(%Resolution{}=info, path) do
    Resolution.project(info)
    |> reproject(path)
    |> Enum.map(& &1.schema_node.identifier)
  end

  def current_user(%Resolution{}=info) do
    case info.context.current_user do
      nil -> {:error, NotLoggedInError.new()}
      user -> {:ok, user}
    end
  end

  def guest_only(%Resolution{}=info) do
    case info.context.current_user do
      nil -> :ok
      user -> {:error, NotPermittedError.new()}
    end
  end

  def reproject(projection, []), do: projection
  def reproject(projection, [key | keys]) do
    case Enum.find(projection, &(&1.schema_node.identifier == key)) do
      nil -> []
      node -> reproject(node.selections, keys)
    end
  end

end
