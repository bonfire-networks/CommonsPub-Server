defmodule MoodleNet.Repo.Migrations.FollowCount do
  use Ecto.Migration

  def up do
    :ok = execute """
    create view mn_follow_count as
    select mn_follow.creator_id as creator_id, count(mn_follow.id) as count
    from mn_follow
    where mn_follow.deleted_at is null
    group by mn_follow.creator_id
    """
  end

  def down do
    :ok = execute "drop view mn_follow_count"
  end

end
