# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Storage do
  @type file_id :: binary

  @spec store(file :: any) :: {:ok, %Belt.FileInfo{}} | {:error, term}
  def store(file) do
    # TODO: handle different types of files
    # TODO: extract metadata
    upload_provider() |> Belt.store(file.path)
  end

  @spec remote_url(file_id()) :: {:ok, binary} | {:error, term}
  def remote_url(file_id) do
    upload_provider |> Belt.get_url(file_id)
  end

  @spec delete(file_id()) :: :ok | {:error, term}
  def delete(file_id) do
    upload_provider |> Belt.delete(file_id)
  end

  defp upload_provider do
    provider = Application.fetch_env!(:moodle_net, __MODULE__) |> Map.fetch(:provider)

    case provider do
      _ when is_atom(provider) -> provider.new()
      [provider, config] when is_atom(provider) -> apply(provider, :new, config)
    end
  end
end
