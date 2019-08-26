defmodule MoodleNetWeb.Uploader do
  def store(definition, file, scope \\ nil) do
    with {:ok, ref_url} <- definition.store({file, scope}) do
      urls = definition.urls({ref_url, scope})
      uploads = for {version, url} <- urls, into: %{} do
        {:ok, metadata} = file_metadata(url)
        file_info = %{
          url: resolve_url(url),
          media_type: format_to_media_type(metadata[:format]),
          metadata: metadata
        }
        {version, file_info}
      end

      {:ok, uploads}
    end
  end

  defp resolve_url(url) do
    MoodleNetWeb.base_url()
    |> URI.merge(url)
    |> to_string()
    |> URI.encode()
  end

  defp file_metadata(url) do
    path = url
    |> URI.parse()
    |> Map.fetch!(:path)
    # FIXME: relative path can break, use upload path
    |> Path.relative()

    with {:ok, binary} <- file_binary(%{path: path}) do
      case FormatParser.parse(binary) do
        info when is_map(info) ->
          {:ok, Map.take(info, [:format, :width_px, :height_px])}

        other ->
          other
      end
    end
  end

  defp file_binary(%{binary: binary}) do
    {:ok, binary}
  end

  defp file_binary(%{path: path}) do
    with {:ok, binary} <- File.read(path) do
      {:ok, binary}
    end

    {:ok, File.read!(path)}
  end

  defp format_to_media_type(format) do
    # HACK: format_parser.ex uses a weird format, returning what seems to mostly
    # be an atom of the file type. E.g. `test-image.png` => `:png`.
    maybe_ext = to_string(format)
    MIME.type(maybe_ext)
  end
end
