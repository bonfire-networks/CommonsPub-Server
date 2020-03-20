# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.Missing do
  use Ecto.Migration

  def up do

    # for whatever stupid reason, min and max are not defined over
    # uuid even though you can compare them for ordering.  we only
    # actually need max at the time of writing, but we may as well
    # define min while we're here
    :ok = execute """
    create function min_uuid(uuid, uuid)
    returns uuid as $$
    begin
       if $1 is null then return $2; end if;
       if $2 is null then return $1; end if;
       if $2 > $1 then return $1; end if;
       return $2;
    end;
    $$ LANGUAGE plpgsql
    """

    :ok = execute """
    create function max_uuid(uuid, uuid)
    returns uuid as $$
    begin
       if $1 is null then return $2; end if;
       if $2 is null then return $1; end if;
       if $1 > $2 then return $1; end if;
       return $2;
    end;
    $$ LANGUAGE plpgsql
    """

    :ok = execute """
    create aggregate min(uuid) (
      sfunc = min_uuid,
      stype = uuid,
      combinefunc = min_uuid,
      parallel = safe,
      sortop = operator (<)
    )
    """

    :ok = execute """
    create aggregate max(uuid) (
      sfunc = max_uuid,
      stype = uuid,
      combinefunc = max_uuid,
      parallel = safe,
      sortop = operator (<)
    )
    """

    # last created comment in the thread

    :ok = execute """
    create view mn_thread_last_comment as
    select mn_comment.thread_id as thread_id, max(mn_comment.id) as comment_id
    from mn_comment
    group by mn_comment.thread_id
    """

    :ok = execute """
    create view mn_user_last_activity as
    select mn_user.id as user_id, max(mn_feed_activity.id) as activity_id
    from mn_user left join mn_feed_activity
    on mn_user.outbox_id = mn_feed_activity.feed_id
    group by mn_user.id
    """

    :ok = execute """
    create view mn_community_last_activity as
    select mn_community.id as community_id, max(mn_feed_activity.id) as activity_id
    from mn_community left join mn_feed_activity
    on mn_community.outbox_id = mn_feed_activity.feed_id
    group by mn_community.id
    """

    :ok = execute """
    create view mn_collection_last_activity as
    select mn_collection.id as collection_id, max(mn_feed_activity.id) as activity_id
    from mn_collection left join mn_feed_activity
    on mn_collection.outbox_id = mn_feed_activity.feed_id
    group by mn_collection.id
    """

    :ok = execute """
    create view mn_follower_count as
    select mn_follow.context_id as context_id, count(mn_follow.id) as count
    from mn_follow
    where mn_follow.deleted_at is null
    group by mn_follow.context_id
    """

    :ok = execute """
    create view mn_liker_count as
    select mn_like.context_id as context_id, count(mn_like.id) as count
    from mn_like
    where mn_like.deleted_at is null
    group by mn_like.context_id
    """

    :ok = execute "drop view if exists mn_user_follower_count"
    :ok = execute "drop view if exists mn_user_following_count"
    :ok = execute "drop view if exists mn_community_follower_count"
    :ok = execute "drop view if exists mn_collection_follower_count"
    :ok = execute "drop view if exists mn_thread_follower_count"

  end

  def down do

    :ok = execute "drop view if exists mn_follower_count"
    :ok = execute "drop view if exists mn_liker_count"

    ### follower counts - copypasta from refactor migration to preserve downness

    :ok = execute """
    create view mn_user_follower_count as
    select mn_user.id as user_id,
           coalesce(count(mn_follow.creator_id), 0) as count
    from mn_user left join mn_follow on mn_user.id = mn_follow.context_id
    where mn_follow.deleted_at is null
    group by mn_user.id
    """

    :ok = execute """
    create view mn_community_follower_count as
    select mn_community.id as community_id,
           coalesce(count(mn_follow.creator_id), 0) as count
    from mn_community left join mn_follow on mn_community.id = mn_follow.context_id
    where mn_follow.deleted_at is null
    group by mn_community.id
    """
    :ok = execute """
    create view mn_collection_follower_count as
    select mn_collection.id as collection_id,
           coalesce(count(mn_follow.creator_id), 0) as count
    from mn_collection left join mn_follow on mn_collection.id = mn_follow.context_id
    where mn_follow.deleted_at is null
    group by mn_collection.id
    """

    :ok = execute """
    create view mn_thread_follower_count as
    select mn_thread.id as thread_id,
           coalesce(count(mn_follow.creator_id), 0) as count
    from mn_thread left join mn_follow on mn_thread.id = mn_follow.context_id
    where mn_follow.deleted_at is null
    group by mn_thread.id
    """

    :ok = execute "drop view mn_collection_last_activity"
    :ok = execute "drop view mn_community_last_activity"
    :ok = execute "drop view mn_user_last_activity"
    :ok = execute "drop view mn_thread_last_comment"
    :ok = execute "drop aggregate max(uuid)"
    :ok = execute "drop aggregate min(uuid)"
    :ok = execute "drop function max_uuid(uuid, uuid)"
    :ok = execute "drop function min_uuid(uuid, uuid)"
  end

end
