# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  @moduledoc """
  Performs the GraphQL Resource queries.
  """
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  alias MoodleNet.Resources
  alias MoodleNetWeb.GraphQL.Errors

  def fetch(%{resource_id: resource_id}, info) do
  end
  
  def create(%{resource: attrs, collection_id: collection_id}, info) do
  end

  def update(%{resource: changes, resource_id: resource_id}, info) do
  end

  def delete(%{resource_id: resource_id}, info) do
  end

  def copy(%{resource_id: resource_id, collection_id: collection_id}, info) do
  end

end
