defmodule MoodleNet.ReleaseTasks do
    @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql # If using Ecto 3.0 or higher
  ]

  @repos Application.get_env(:moodle_net, :ecto_repos, [])

  def create_db(_) do
    start_apps()

    Enum.each(@repos, &create_repo/1)

    stop_services()
  end

  defp create_repo(repo) do
    case repo.__adapter__.storage_up(repo.config) do
      :ok ->
        IO.puts("The database for #{inspect(repo)} has been created")

      {:error, :already_up} ->
        IO.puts("The database for #{inspect(repo)} has already been created")

      {:error, term} when is_binary(term) ->
        raise "The database for #{inspect(repo)} couldn't be created: #{term}"
    end
  end

  def migrate_db(_) do
    start_apps()
    start_repos()
    Enum.each(@repos, &migrate_repo/1)

    stop_services()
  end

  defp migrate_repo(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  def rollback_db(_) do
    start_apps()
    start_repos()

    Enum.each(@repos, &rollback_repo/1)

    stop_services()
  end

  defp rollback_repo(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running rollback for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :down, step: 1)
  end

  def seed_db(_) do
    start_apps()

    start_repos()

    Enum.each(@repos, &migrate_repo/1)

    Enum.each(@repos, &seed_repo/1)

    stop_services()
  end

  defp seed_repo(repo) do
     # Run the seed script if it exists
    seed_script = priv_path_for(repo, "seeds.exs")

    if File.exists?(seed_script) do
      IO.puts("Running seed script..")
      Code.eval_file(seed_script)
    end
  end

  def drop_db([]) do
    start_apps()

    Enum.each(@repos, &drop_repo/1)

    stop_services()
  end

  defp drop_repo(repo) do
    case repo.__adapter__.storage_down(repo.config) do
      :ok ->
        IO.puts("The database for #{inspect(repo)} has been dropped")

      {:error, :already_down} ->
        IO.puts("The database for #{inspect(repo)} has already been dropped")

      {:error, term} when is_binary(term) ->
        raise "The database for #{inspect(repo)} couldn't be dropped: #{term}"
    end
  end

  defp start_apps() do
    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)
  end

  defp start_repos() do
    # Start the Repo(s) for app
    IO.puts("Starting repos..")
    
    # Switch pool_size to 2 for ecto > 3.0
    Enum.each(@repos, & &1.start_link(pool_size: 2))
  end

  defp stop_services() do
    IO.puts("Success!")
    :init.stop()
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end
end
