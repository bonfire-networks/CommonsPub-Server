# this code is based on Absinthe library: Absinthe.Phase.Document.Execution.Resolution
defmodule MoodleNetWeb.GraphQL.Phase.ExecutionResolution do
  @moduledoc false

  # Runs resolution functions in a blueprint.
  #
  # Blueprint results are placed under `blueprint.result.execution`. This is
  # because the results form basically a new tree from the original blueprint.

  alias Absinthe.{Blueprint, Type, Phase}
  alias Blueprint.{Result, Execution}

  alias Absinthe.Phase
  use Absinthe.Phase

  require Logger

  def run(bp_root, options \\ []) do
      Absinthe.Phase.Document.Execution.Resolution.run(bp_root, options)
  rescue
      error -> debug_exception("The API encountered an exceptional error", error, __STACKTRACE__, :error)
  catch
      error -> debug_exception("The API was thrown an exceptional error", error, __STACKTRACE__, :error)
  end

  defp debug_exception(msg, exception, stacktrace, kind) do
    debug_log(msg, exception, stacktrace, kind)
    if Application.get_env(:moodle_net, :env) == :dev or System.get_env("SENTRY_ENV") == "next" do
      {:error, msg 
        <> ": " 
        <> Exception.format_banner(kind, exception, stacktrace)
        <> " -- Details: " 
        <> Exception.format_stacktrace(stacktrace) 
      }
    else
      {:error, msg}
    end
  end

  defp debug_log(msg, exception, stacktrace, kind) do
    Logger.error(msg)
    Logger.error(Exception.format_banner(kind, exception, stacktrace))
    IO.puts(Exception.format_exit(exception))
    IO.puts(Exception.format_stacktrace(stacktrace))
    Sentry.capture_exception(
      exception,
      stacktrace: stacktrace
    )
  end

end
