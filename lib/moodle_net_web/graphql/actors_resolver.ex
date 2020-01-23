# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActorsResolver do
  @moduledoc """
  Resolver functions shared between actor types.
  """
  alias MoodleNet.Actors.Actor
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  
  @doc "Returns the canonical url for the actor"
  def canonical_url_edge(%{actor: %Actor{canonical_url: u}}, _, _), do: {:ok, u}

  @doc "Returns the preferred_username for the actor"
  def preferred_username_edge(%{actor: %Actor{preferred_username: u}}, _, _), do: {:ok, u}

  @doc "Is this actor local to this instance?"
  def is_local_edge(%{actor: %Actor{peer_id: id}}, _, _), do: {:ok, is_nil(id)}

end
