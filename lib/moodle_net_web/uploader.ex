defmodule MoodleNetWeb.Uploader do
  @type file_info :: %{
          url: binary(),
          media_type: binary(),
          metadata: map()
        }

  @doc """
  Store a file using an Arc uploader.

  Will return a map, where each key corresponds to a "version" of the file (if the
  file has been transformed for example) and the value containing a map of file
  information.
  """
  @spec store(definition :: atom, file :: any, scope :: any) :: {:ok, file_info} | {:error, term}
  def store(definition, file, scope \\ nil) do
    if File.exists?(file.path) do
      uploads = for version <- definition.versions() do
        put_version(definition, version, file, scope)
      end

      case handle_errors(uploads) do
        [] ->
          uploads = uploads
          |> Enum.map(fn {_status, upload} -> upload end)
          |> Enum.into(%{})
          {:ok, uploads}

        errors ->
          {:error, errors}
      end
    else
      {:error, :invalid_file_path}
    end
  end

  defp handle_errors(uploads) do
    uploads
    |> Enum.filter(fn upload -> elem(upload, 0) == :error end)
    |> Enum.map(fn {_, reason} -> reason end)
  end

  defp put_version(definition, version, file, scope) do
    if definition.valid?(file, scope) do
      with {:ok, tmp_file} <- do_transformation(definition, version, file, scope),
           {:ok, file} <- put_file(definition, version, tmp_file, scope),
           {:ok, metadata} <- get_metadata(file) do
        file_info = %{
          url: path_to_url(file.path),
          media_type: format_to_media_type(metadata[:format]),
          metadata: metadata
        }

        {:ok, {version, file_info}}
      end
    else
      {:error, :invalid_file}
    end
  end

  # TODO: move behind a behaviour
  defp put_file(definition, version, file, scope) do
    destination_dir = Application.fetch_env!(:moodle_net, :upload_dir)
    filename = definition.filename(version, file, scope)
    path = Path.join(destination_dir, filename)

    # ensure parent directories are there
    path |> Path.dirname() |> File.mkdir_p!()
    File.copy!(file.path, path)

    {:ok, %{file | path: path}}
  end

  defp do_transformation(definition, version, file, scope) do
    case definition.transform(version, file, scope) do
      :skip -> {:ok, file}
      {cmd, args} ->
        new_path = MoodleNet.File.generate_temporary_path(file)
        # assumes a certain command line format for programs
        with :ok <- run_command(cmd, [file.path | args] ++ [new_path]),
          do: {:ok, Map.put(file, :path, new_path)}
    end
  end

  defp run_command(cmd, args) when is_list(args) do
    executable = to_string(cmd)
    ensure_executable_exists!(executable)

    case System.cmd(executable, args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      {message, _exit_code} -> {:error, message}
    end
  end

  defp ensure_executable_exists!(executable) do
    unless System.find_executable(executable) do
      raise "Missing executable: #{executable}"
    end
  end

  defp path_to_url(path) do
    MoodleNetWeb.base_url()
    |> URI.merge(path)
    |> to_string()
    |> URI.encode()
  end

  defp get_metadata(%{path: path}) do
    with {:ok, binary} <- File.read(path) do
      case FormatParser.parse(binary) do
        info when is_map(info) ->
          {:ok, Map.take(info, [:format, :width_px, :height_px])}

        other ->
          other
      end
    end
  end

  defp format_to_media_type(format) do
    # HACK: format_parser.ex uses a weird format, returning what seems to mostly
    # be an atom of the file type. E.g. `test-image.png` => `:png`.
    maybe_ext = to_string(format)
    MIME.type(maybe_ext)
  end
end
