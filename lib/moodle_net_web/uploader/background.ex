# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Uploader.Background do
  use Arc.Definition

  @moduledoc """
  A background image uploader definition.

  Will resize an image down to a maximum size if exceeded.
  """

  @extension_whitelist ~w(.jpg .jpeg .png)
  @max_size {3000, 3000}

  @versions [:full]

  def validate({file, _}) do
    MoodleNet.File.has_extension?(file.file_name, @extension_whitelist)
  end

  def filename(_, {file, local_id}) when is_integer(local_id) do
    file_name = MoodleNet.File.basename(file.file_name)
    Path.join([to_string(local_id), file_name])
  end

  def transform(:full, _) do
    {max_width, max_height} = @max_size
    # note the '>' symbol at the end, this means only resize if those
    # dimensions are exceeded.
    {:convert, "-resize #{max_width}x#{max_height}>"}
  end
end
