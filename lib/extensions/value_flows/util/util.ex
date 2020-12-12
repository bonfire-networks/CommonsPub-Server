# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Util do
  import Bonfire.Common.Utils

  # def try_tag_thing(user, thing, attrs) do
  #   IO.inspect(attrs)
  # end

  @doc """
  lookup tag from URL(s), to support vf-graphql mode
  """

  # def try_tag_thing(_user, thing, %{resource_classified_as: urls})
  #     when is_list(urls) and length(urls) > 0 do
  #   # todo: lookup tag by URL
  #   {:ok, thing}
  # end

  def try_tag_thing(user, thing, tags) do
    CommonsPub.Tag.TagThings.try_tag_thing(user, thing, tags)
  end

  def activity_create(creator, item, act_attrs) do
    CommonsPub.Activities.create(creator, item, act_attrs)
  end

  def publish(creator, thing, activity, :created) do
    feeds = [
      CommonsPub.Feeds.outbox_id(creator),
      CommonsPub.Feeds.instance_outbox_id()
    ]

    with :ok <- CommonsPub.Feeds.FeedActivities.publish(activity, feeds) do
      ValueFlows.Util.Federation.ap_publish("create", thing.id, creator.id)
    end
  end

  def publish(creator, nil, thing, activity, :created),
    do: publish(creator, thing, activity, :created)

  def publish(creator, context, thing, activity, :created) do
    feeds = [
      context.outbox_id,
      CommonsPub.Feeds.outbox_id(creator),
      CommonsPub.Feeds.instance_outbox_id()
    ]

    with :ok <- CommonsPub.Feeds.FeedActivities.publish(activity, feeds) do
      ValueFlows.Util.Federation.ap_publish("create", thing.id, creator.id)
    end
  end

  def publish(thing, :updated) do
    # TODO: wrong if edited by admin
    ValueFlows.Util.Federation.ap_publish("update", thing.id, thing.creator_id)
  end

  def publish(thing, :deleted) do
    # TODO: wrong if edited by admin
    ValueFlows.Util.Federation.ap_publish("delete", thing.id, thing.creator_id)
  end

  def image_url(%{profile_id: profile_id} = thing) when not is_nil(profile_id) do
    Bonfire.Repo.maybe_preload(thing, :profile)
    |> Map.get(:profile)
    |> image_url()
  end

  def image_url(%{icon_id: icon_id} = thing) when not is_nil(icon_id) do
    Bonfire.Repo.maybe_preload(thing, icon: [:content_upload, :content_mirror])
    # |> IO.inspect()
    |> Map.get(:icon)
    |> content_url_or_path()
  end

  def image_url(%{image_id: image_id} = thing) when not is_nil(image_id) do
    # IO.inspect(thing)
    Bonfire.Repo.maybe_preload(thing, image: [:content_upload, :content_mirror])
    |> Map.get(:image)
    |> content_url_or_path()
  end

  def image_url(_) do
    nil
  end

  def content_url_or_path(content) do
    e(
      content,
      :content_upload,
      :path,
      e(content, :content_mirror, :url, nil)
    )
  end

  def handle_changeset_errors(cs, attrs, fn_list) do
    Enum.reduce_while(fn_list, cs, fn cs_handler, cs ->
      case cs_handler.(cs, attrs) do
        {:error, reason} -> {:halt, {:error, reason}}
        cs -> {:cont, cs}
      end
    end)
    |> case do
      {:error, _} = e -> e
      cs -> {:ok, cs}
    end
  end
end
