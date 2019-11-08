# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Storage do
  @type file_source :: Belt.file_source()
  @type file_info :: %{info: %Belt.FileInfo{}, media_type: binary, metadata: map}
  @type file_id :: binary

  @spec store(file :: file_source()) :: {:ok, file_info()} | {:error, term}
  def store(file, opts \\ []) do
    opts = [overwrite: true] ++ opts
    with {:ok, file_info} <- upload_provider() |> Belt.store(file, opts),
         {:ok, metadata} <- get_metadata(file) do
      media_type = format_to_media_type(metadata.format)
      {:ok, %{info: file_info, media_type: media_type, metadata: metadata}}
    end
  end

  @spec remote_url(file_id()) :: {:ok, binary} | {:error, term}
  def remote_url(file_id) do
    upload_provider() |> Belt.get_url(file_id)
  end

  @spec delete(file_id()) :: :ok | {:error, term}
  def delete(file_id) do
    upload_provider() |> Belt.delete(file_id)
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

  defp get_metadata(path) when is_binary(path) do
    get_metadata(%{path: path})
  end

  defp get_metadata(%{path: path}) do
    with {:ok, binary} <- File.read(path), do: {:ok, FormatParser.parse(binary)}
  end

  defp format_to_media_type(format) do
    # HACK: format_parser.ex uses a weird format, returning what seems to mostly
    # be an atom of the file type. E.g. `test-image.png` => `:png`.
    maybe_ext = to_string(format)
    MIME.type(maybe_ext)
  end
end
