# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Uploads.Definition do
  alias CommonsPub.Uploads.Storage

  @callback transform(Storage.file_source()) :: {command :: atom, arguments :: [binary]} | :skip

  defmacro __using__(_opts) do
    quote do
      @behaviour CommonsPub.Uploads.Definition
    end
  end
end
