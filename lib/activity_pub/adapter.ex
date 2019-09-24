# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Adapter do
  @moduledoc """
  Contract for ActivityPub module adapters
  """

  alias ActivityPub.Object
  alias MoodleNet.Config

  @adapter Config.get!(ActivityPub.Adapter)[:adapter]

  @doc """
  Fetch an actor given an URI string identifying that actor
  """
  @callback get_actor_by_ap_id(String.t()) :: {:ok, any()} | {:error, any()}
  defdelegate get_actor_by_ap_id(ap_id), to: @adapter

  @doc """
  Fetch an actor given its preferred username
  """
  @callback get_actor_by_username(String.t()) :: {:ok, any()} | {:error, any()}
  defdelegate get_actor_by_username(username), to: @adapter

  @doc """
  Passes data to be handled by the host application
  """
  @callback handle_activity(Object.t()) :: :ok | {:error, any()}
  defdelegate handle_activity(activity), to: @adapter

  def maybe_handle_activity(%Object{local: false} = activity), do: handle_activity(activity)

  def maybe_handle_activity(_), do: :ok
end
