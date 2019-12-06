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

  def run_with_debug(module, fun, job, arg) when is_function(fun,1) do
    try do
      configure_logger(module)
      fun.(arg)
    catch
      reason -> debug(reason, __STACKTRACE__)
    rescue
      reason -> debug(reason, __STACKTRACE__)
    end
  end

  defp debug(reason, trace) do
    Logger.error(
	    "[ActivityWorker] Failed to #{inspect(verb)} " <>
        "context #{inspect(context_id)} " <>
        "for #{inspect(user_id)}: #{inspect(reason)}"
	  )
    if Mix.env == :dev do
      IO.puts(Exception.format_stacktrace(trace))
    else
      Sentry.capture_exception
    end
  end

end
