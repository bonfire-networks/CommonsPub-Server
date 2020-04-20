# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.ResolveFields do
  @moduledoc """
  Encapsulates the flow for resolving a field in the absence of
  multiple parents.
  """

  @enforce_keys [:module, :fetcher, :context, :info]
  defstruct [
    :module, :fetcher, :context, :info,
    default: nil,
    getter_fn: &__MODULE__.default_getter/2,
  ]

  import Absinthe.Resolution.Helpers, only: [batch: 3]
  alias MoodleNet.GraphQL.ResolveFields

  @type getter :: (%{term => term} -> term)

  @type t :: %ResolveFields{
    module: atom,
    fetcher: atom,
    context: term,
    info: map,
    default: term,
    getter_fn: ((context :: term, default :: term) -> getter),
  }

  def run(
    %ResolveFields{
      module: module,
      fetcher: fetcher,
      context: context,
      info: info,
      default: default,
      getter_fn: getter,
    }
  ) when is_function(getter, 2) do
    batch {module, fetcher, Map.take(info, [:context])},
      context, getter.(context, default)
  end
  
end
