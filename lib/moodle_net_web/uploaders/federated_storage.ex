# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Uploaders.FederatedStorage do
  @moduledoc """
  Storage to be plugged in to Arc for use inside of a federated network.

  It ensures URL's are formatted correctly, according to federation server
  rather than just a local path, which is what `Arc.Storage.Local` gives you.
  """

  def put(definition, version, {file, scope}) do
    destination_dir = definition.storage_dir(version, {file, scope})
    path = Path.join(destination_dir, file.file_name)
    path |> Path.dirname() |> File.mkdir_p!()

    if binary = file.binary do
      File.write!(path, binary)
    else
      File.copy!(file.path, path)
    end

    {:ok, url(definition, version, {file, scope})}
  end

  def url(definition, version, file_and_scope, _options \\ []) do
    local_path = build_local_path(definition, version, file_and_scope)

    url = if String.starts_with?(local_path, "/") do
      local_path
    else
      "/" <> local_path
    end

    # TODO: replace base_url() with configuration
    MoodleNetWeb.base_url()
    |> URI.merge(url)
    |> to_string()
    |> URI.encode()
  end

  def delete(definition, version, file_and_scope) do
    build_local_path(definition, version, file_and_scope)
    |> File.rm()
  end

  defp build_local_path(definition, version, file_and_scope) do
    Path.join([
      definition.storage_dir(version, file_and_scope),
      Arc.Definition.Versioning.resolve_file_name(definition, version, file_and_scope)
    ])
  end
end
