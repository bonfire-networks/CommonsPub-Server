# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Uploaders.Avatar do
  use Arc.Definition

  @moduledoc """
  A profile image/avatar definition.

  Will resize images so that they are clamped to a maximum size and also generate
  thumbnail versions of each image.
  """

  # Allowed extensions.
  @extension_whitelist ~w(.jpg .jpeg .png)
  # The size to resize thumbnail images to.
  @thumbnail_size {300, 300}
  # The maximum size for an image, anything larger is resized.
  @max_size {1000, 1000}

  @versions [:full, :thumbnail]

  def validate({file, _}) do
    MoodleNet.File.has_extension?(file.file_name, @extension_whitelist)
  end

  def filename(version, {file, local_id}) when is_integer(local_id) do
    file_name = MoodleNet.File.basename(file.file_name)
    Path.join([to_string(local_id), "#{version}_#{file_name}"])
  end

  def transform(:thumbnail, _) do
    {w, h} = @thumbnail_size
    {:convert, "-strip -thumbnail #{w}x#{h} -gravity center -extent #{w}x#{h}"}
  end

  def transform(:full, _) do
    {max_width, max_height} = @max_size
    # note the '>' symbol at the end, this means only resize if those
    # dimensions are exceeded.
    {:convert, "-resize #{max_width}x#{max_height}>"}
  end
end
