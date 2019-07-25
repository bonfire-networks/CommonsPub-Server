defmodule MoodleNetWeb.Uploaders.Background do
  use Arc.Definition

  @moduledoc """
  A background image uploader definition.

  Will resize an image down to a maximum size if exceeded.
  """

  @extension_whitelist ~w(.jpg .jpeg .png)
  @max_size {3000, 3000}

  @versions [:original]

  def validate({file, _}) do
    MoodleNet.File.has_extension?(file.file_name, @extension_whitelist)
  end

  def filename(_, {file, _}), do: MoodleNet.File.basename(file.file_name)

  def transform(:original, _) do
    {max_width, max_height} = @max_size
    # note the '>' symbol at the end, this means only resize if those
    # dimensions are exceeded.
    {:convert, "-resize #{max_width}x#{max_height}>"}
  end
end
