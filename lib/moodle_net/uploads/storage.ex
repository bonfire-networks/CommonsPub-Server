# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Storage do
  @type file_source :: Belt.Provider.file_source()
  @type file_info :: %{info: %Belt.FileInfo{}, media_type: binary, metadata: map}
  @type file_id :: binary

  @spec store(upload_def :: any, file :: file_source()) :: {:ok, file_info()} | {:error, term}
  def store(upload_def, file, opts \\ []) do
    with {:ok, file} <- allow_extension(upload_def, file),
         {:ok, media_type} <- get_media_type(file),
         {:ok, file_info} <- upload_provider() |> Belt.store(file, opts),
         {:ok, metadata} <- get_metadata(file) do
      {:ok,
       %{id: file_info.identifier, info: file_info, media_type: media_type, metadata: metadata}}
    end
  end

  @spec remote_url(file_id()) :: {:ok, binary} | {:error, term}
  def remote_url(file_id) do
    with {:ok, url} <- upload_provider() |> Belt.get_url(file_id) do
      {:ok, URI.encode(url)}
    end
  end

  @spec delete(file_id()) :: :ok | {:error, term}
  def delete(file_id) do
    upload_provider() |> Belt.delete(file_id)
  end

  @scope :test
  @spec delete_all() :: :ok | {:error, term}
  def delete_all do
    upload_provider() |> Belt.delete_all()
  end

  defp upload_provider do
    provider_config = Application.fetch_env!(:moodle_net, __MODULE__) |> Keyword.fetch!(:provider)

    {:ok, provider} =
      case provider_config do
        provider when is_atom(provider) -> provider.new()
        [provider, config] when is_atom(provider) -> apply(provider, :new, config)
      end

    provider
  end

  defp get_media_type(%{path: path}), do: TreeMagic.from_filepath(path)

  defp get_metadata(%{path: path}) do
    with {:ok, binary} <- File.read(path) do
      case FormatParser.parse(binary) do
        {:error, "Unknown"} -> {:ok, %{}}
        info when is_map(info) -> {:ok, Map.from_struct(info)}
        other -> other
      end
    end
  end

  defp allow_extension(upload_def, path) when is_binary(path) do
    allow_extension(upload_def, %{path: path, filename: Path.basename(path)})
  end

  defp allow_extension(upload_def, %{filename: filename} = file) do
    case upload_def.allowed_extensions() do
      :all ->
        {:ok, file}

      allowed ->
        if MoodleNet.File.has_extension?(filename, allowed) do
          {:ok, file}
        else
          {:error, :extension_denied}
        end
    end
  end
end
