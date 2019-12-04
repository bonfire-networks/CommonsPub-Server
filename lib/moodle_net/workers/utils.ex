defmodule MoodleNet.Workers.Utils do

  require Logger
  
  defp get_log_level(key \\ MoodleNet.Workers) when is_atom(key) do
    Application.get_env(:moodle_net, key, [])
    |> Keyword.get(:log_level, :warn)
  end

  @doc "set up the logger for this worker, defaults to log level warn"
  def configure_logger(key \\ MoodleNet.Workers, overrides \\ []) do
    overrides
    |> Keyword.put_new_lazy(:log_level, fn -> get_log_level(key) end)
    |> Logger.configure() 
  end

end
