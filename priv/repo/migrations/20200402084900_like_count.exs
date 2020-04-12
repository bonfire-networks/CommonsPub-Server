defmodule MoodleNet.Repo.Migrations.LikeCount do
  use Ecto.Migration

  def up do
    :ok = execute """
    create view mn_like_count as
    select mn_like.creator_id as creator_id, count(mn_like.id) as count
    from mn_like
    where mn_like.deleted_at is null
    group by mn_like.creator_id
    """
  end

  def down do
    :ok = execute "drop view mn_like_count"
  end

end
