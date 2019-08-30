# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Uploader.Background do
  use MoodleNetWeb.Uploader.Definition

  @moduledoc """
  A background image uploader definition.

  Will resize an image down to a maximum size if exceeded.
  """

  @extension_whitelist ~w(.jpg .jpeg .png)
  @max_size {3000, 3000}

  def versions, do: [:full]

  def valid?(file, _) do
    MoodleNet.File.has_extension?(file.filename, @extension_whitelist)
  end

  def filename(_, file, local_id) when is_integer(local_id) do
    Path.join([to_string(local_id), file.filename])
  end

  def transform(:full, _, _) do
    {max_width, max_height} = @max_size
    # note the '>' symbol at the end, this means only resize if those
    # dimensions are exceeded.
    {:convert, ~w(-resize #{max_width}x#{max_height}>)}
  end
end
