# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.ResolveField do
  @moduledoc """
  Encapsulates the flow for resolving a field in the absence of
  multiple parents.
  """

  @enforce_keys [:module, :fetcher, :context, :info]
  defstruct @enforce_keys

  alias MoodleNet.GraphQL.ResolveField

  def run(
    %ResolveField{
      module: module,
      fetcher: fetcher,
      context: context,
      info: info,
    }
  ) do
    info2 = Map.take(info, [:context]) # not strictly required - no batch
    apply(module, fetcher, [info2, context])
  end
  
end
