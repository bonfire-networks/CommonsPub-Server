defmodule MoodleNet.Queue do
  
  def submit()
  def attempt()
  def complete()
  def fail()
end
defmodule MoodleNet.Queue.Job do
  @enforce_keys [:data, :retries]
  defstruct @enforce_keys

  @default_retries 3
  def new(data, retries \\ @default_retries)
  when is_integer(retries) and retries >= 0,
    do: %__MODULE__{data: data, retries: retries}
end
defmodule MoodleNet.Queue.Ecto do
  defstruct @enforce_keys
  use GenServer
  alias MoodleNet.Queue.EctoServer

end
defmodule MoodleNet.Queue.Server do
  use GenServer
  def init(%ServerConfig{}=conf) do
    {:ok, conf}
  end
  
end
defmodule MoodleNet.Queue.Macros do
  
  defmacro queue_fields() when is_binary(name) do
    quote do
      field(:data, :map)
      field(:retries, :integer)
      field(:attempted_at, :utc_timestamp_usec)
      field(:failed_at, :utc_timestamp_usec)
      field(:completed, :utc_timestamp_usec)
      timestamps()
    end
  end

end
