defmodule MoodleNetWeb.Uploaders.Avatar do
  use Arc.Definition

  @moduledoc """
  An avatar definition, used for profile pictures.

  Will resize images so that they are clamped to a maximum size and also generate
  thumbnail versions of each image.
  """

  # Allowed extensions.
  @extension_whitelist ~w(.jpg .jpeg .png)
  # The size to resize thumbnail images to.
  @thumbnail_size {150, 150}
  # The maximum size for an image, anything larger is resized.
  @max_size {500, 500}

  @versions [:original, :thumbnail]

  def validate({file, _}) do
    MoodleNet.File.has_extension?(file.file_name, @extension_whitelist)
  end

  def filename(version, {file, _}) do
    file_name = MoodleNet.File.basename(file.file_name)
    "#{version}_#{file_name}"
  end

  def transform(:thumbnail, _) do
    {w, h} = @thumbnail_size
    {:convert, "-strip -thumbnail #{w}x#{h} -gravity center -extent #{w}x#{h}"}
  end

  def transform(:original, _) do
    {max_width, max_height} = @max_size
    # note the '>' symbol at the end, this means only resize if those
    # dimensions are exceeded.
    {:convert, "-resize #{max_width}x#{max_height}>"}
  end
end
