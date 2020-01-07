defmodule MoodleNet.Repo.Migrations.AddInstanceFeeds do
  use Ecto.Migration

  @instance_outbox_id "10CA11NSTANCE00TB0XFEED1D0"
  @instance_inbox_id "10CA11NSTANCE1NB0XFEED1D00"
  def up do
    {:ok, outbox} = Ecto.ULID.dump(@instance_outbox_id)
    {:ok, outbox} = Ecto.UUID.cast(outbox)
    {:ok, inbox} = Ecto.ULID.dump(@instance_inbox_id)
    {:ok, inbox} = Ecto.UUID.cast(inbox)
    :ok = execute """
    insert into mn_feed (id) values ('#{inbox}'), ('#{outbox}')
    """
  end

  # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
  # necessary, regardless of which version we've migrated `up` to.
  def down do
    Oban.Migrations.down(version: 1)
  end
end
