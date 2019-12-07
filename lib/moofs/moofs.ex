# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Moofs do
  @type file_source :: %{path: binary} | %Plug.Upload{} | binary
  @type file_id :: binary

  def list() do
  end

  def remote_url() do
  end

  def store() do
  end

  def delete(file_id) do
  end

  @scope :test
  def delete_all do
  end
end
