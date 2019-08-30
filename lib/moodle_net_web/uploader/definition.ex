defmodule MoodleNetWeb.Uploader.Definition do
  @type file :: %Plug.Upload{} | %{path: Path.t()} | %{binary: binary} | binary
  @type scope :: any
  @type version :: atom

  @callback versions() :: [version]
  @callback valid?(file, scope) :: boolean
  @callback filename(version, file, scope) :: Path.t()
  @callback transform(version, file, scope) :: {command :: atom, arguments :: [binary]} | :skip

  def __using__(opts) do
    quote do
      @behaviour __MODULE__
    end
  end
end
