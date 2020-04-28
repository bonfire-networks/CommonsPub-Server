defmodule MoodleNet.Workers.Utils do

  require Logger
  
  defp get_log_level(key)
  defp get_log_level(key) when is_atom(key) do
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
    rescue
      cause ->
        debug_exception(module, cause, job, __STACKTRACE__)
        {:error, cause}
    catch
      cause ->
        debug_throw(module, cause, job, __STACKTRACE__)
        {:error, cause}
    end
  end

  if Mix.env == :dev do
    defp debug_exception(module, exception, job, stacktrace),
      do: debug_log(job, stacktrace)

    defp debug_throw(module, thrown, job, stacktrace),
      do: debug_log(job, stacktrace)
  else
    defp debug_exception(module, exception, job, stacktrace) do
      sentry_raised(module, exception, job, stacktrace)
    end

    defp debug_throw(module, thrown, job, stacktrace),
      do: sentry_thrown(module, thrown, job, stacktrace)
  end

  defp sentry_raised(module, exception, job, stacktrace) do
    Sentry.capture_exception(
      exception,
      stacktrace: stacktrace,
      event_source: module,
      extra: %{job: job},
      level: :error
    )
  end

  defp sentry_thrown(module, thrown, job, stacktrace) do
    Sentry.Event.create_event(
      message: "Worker Job failed",
      stacktrace: stacktrace,
      event_source: module,
      extra: %{job: job, thrown: thrown},
      level: :error
    )
    |> Sentry.send_event()
  end

  defp debug_log(job, stacktrace) do
    Logger.error("[ActivityWorker] Job failed!")
    # IO.puts(Exception.format_stacktrace(stacktrace))
    # IO.inspect(job: job)
  end

end
