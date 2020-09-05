# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Uploads.IconUploader do
  use CommonsPub.Uploads.Definition

  def transform(_file), do: :skip
end
