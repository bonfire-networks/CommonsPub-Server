# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ReleaseTasks do
  require Logger

  @start_apps [:moodle_net]
  @repos Application.get_env(:moodle_net, :ecto_repos, [])

  def create_db() do
    start_apps()

    create_repos()

    stop_services()
  end

  def create_repos() do
    Enum.each(@repos, &create_repo/1)
  end

  defp create_repo(repo) do
    case repo.__adapter__.storage_up(repo.config) do
      :ok ->
        Logger.info("The database for #{inspect(repo)} has been created")

      {:error, :already_up} ->
        Logger.warn("The database for #{inspect(repo)} has already been created")

      {:error, term} when is_binary(term) ->
        raise "The database for #{inspect(repo)} couldn't be created: #{term}"
    end
  end

  def migrate_db() do
    start_apps()
    start_repos()

    migrate_repos()

    stop_services()
  end

  def migrate_repos() do
    Enum.each(@repos, &migrate_repo/1)
  end

  defp migrate_repo(repo) do
    app = Keyword.get(repo.config, :otp_app)
    migrations_path = priv_path_for(repo, "migrations")
    IO.puts("Running migrations for #{app} from path #{migrations_path}")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  def startup_migrations() do
    if System.get_env("AUTORUN_DB_MIGRATIONS") == "true" do
      start_repos()
      # create_repos()
      migrate_repos()
      stop_repos()
    end
  end

  def rollback_db() do
    start_apps()
    start_repos()

    rollback_repos()

    stop_services()
  end

  def rollback_repos() do
    Enum.each(@repos, &rollback_repo/1)
  end

  def rollback_repos(step) do
    Enum.each(@repos, &rollback_repo(&1, step))
  end

  defp rollback_repo(repo) do
    rollback_repo(repo, 1)
  end

  defp rollback_repo(repo, step) do
    app = Keyword.get(repo.config, :otp_app)
    Logger.info("Running rollback for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :down, step: step)
  end

  def empty_db() do
    start_apps()
    start_repos()

    empty_repos()

    stop_services()
  end

  def empty_repos() do
    Enum.each(@repos, &empty_repo/1)
  end

  defp empty_repo(repo) do
    app = Keyword.get(repo.config, :otp_app)
    Logger.info("Running rollback for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :down, all: true)
  end

  def seed_db() do
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
      Logger.info("Running seed script..")
      Code.eval_file(seed_script)
    end
  end

  def drop_db() do
    start_apps()

    drop_repos()

    stop_services()
  end

  def drop_repos() do
    Enum.each(@repos, &drop_repo/1)
  end

  defp drop_repo(repo) do
    case repo.__adapter__.storage_down(repo.config) do
      :ok ->
        Logger.info("The database for #{inspect(repo)} has been dropped")

      {:error, :already_down} ->
        Logger.warn("The database for #{inspect(repo)} has already been dropped")

      {:error, term} when is_binary(term) ->
        raise "The database for #{inspect(repo)} couldn't be dropped: #{term}"
    end
  end

  defp start_apps() do
    Logger.debug("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)
  end

  def start_repos() do
    # Start the Repo(s) for app
    Logger.debug("Starting repos..")

    # Switch pool_size to 2 for ecto > 3.0
    Enum.each(@repos, & &1.start_link(pool_size: 2))
  end

  def stop_repos() do
    # Stop the Repo(s) for app
    Logger.debug("Stopping repos..")

    Enum.each(@repos, & &1.stop())
  end

  defp stop_services() do
    Logger.info("Success!")
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

  def soft_delete_community(id) do
       {:ok, community} = MoodleNet.Communities.one(id: id)
       {:ok, community} = MoodleNet.Communities.soft_delete(community)
  end

  def user_set_email_confirmed(username) do
    {:ok, u} = MoodleNet.Users.one([:default, username: username])
    MoodleNet.Users.confirm_email(u)
  end

  def make_instance_admin(username) do
    {:ok, u} = MoodleNet.Users.one([:default, username: username])
    MoodleNet.Users.make_instance_admin(u)
  end

  def unmake_instance_admin(username) do
    {:ok, u} = MoodleNet.Users.one([:default, username: username])
    MoodleNet.Users.unmake_instance_admin(u)
  end

  def remove_meta_table(table) do
    import Ecto.Query
    {rows_deleted, _} = from(x in MoodleNet.Meta.Table, where: x.table == ^table) |> MoodleNet.Repo.delete_all
  end
  
end
