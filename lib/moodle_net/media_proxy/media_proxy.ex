# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.MediaProxy do
  @moduledoc """
  A behaviour for fetching media using a proxy.
  """

  @type content_type :: String.t()

  @doc """
  Fetch a stream of binary data, along with its content type, from a remote source.
  """
  @callback fetch(sig :: String.t(), url :: String.t()) ::
              {:ok, content_type(), Stream.t()} | {:error, term}

  @doc """
  Return the current implementation used, as defined by configuration.

  Will return `nil` if there is none.
  """
  @spec current() :: atom | nil
  def current do
    Application.fetch_env!(:moodle_net, MoodleNet.MediaProxy)[:impl]
  end

  @doc """
  Return the URL path used by the media proxy, as defined in configuration.
  """
  @spec media_path() :: String.t()
  def media_path do
    Application.fetch_env!(:moodle_net, MoodleNet.MediaProxy)
    |> Keyword.fetch!(:path)
  end
end
