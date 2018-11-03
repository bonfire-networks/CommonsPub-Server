defmodule MoodleNetWeb.CommonAPI do
  alias MoodleNet.{User, Repo, Activity}
  alias ActivityPub.Object
  alias ActivityPub
  alias MoodleNet.Formatter
  alias MoodleNet.{Repo, Formatter, Activity}
  alias ActivityPub.Object
  alias ActivityPub.Utils
  alias MoodleNetWeb.Endpoint
  alias MoodleNet.User
  alias Calendar.Strftime
  alias Comeonin.Pbkdf2

  def delete(activity_id, user) do
    with %Activity{data: %{"object" => %{"id" => object_id}}} <- Repo.get(Activity, activity_id),
         %Object{} = object <- Object.normalize(object_id),
         true <- user.info["is_moderator"] || user.ap_id == object.data["actor"],
         {:ok, delete} <- ActivityPub.delete(object) do
      {:ok, delete}
    end
  end

  def repeat(id_or_ap_id, user) do
    with %Activity{} = activity <- get_by_id_or_ap_id(id_or_ap_id),
         object <- Object.normalize(activity.data["object"]["id"]) do
      ActivityPub.announce(user, object)
    else
      _ ->
        {:error, "Could not repeat"}
    end
  end

  def unrepeat(id_or_ap_id, user) do
    with %Activity{} = activity <- get_by_id_or_ap_id(id_or_ap_id),
         object <- Object.normalize(activity.data["object"]["id"]) do
      ActivityPub.unannounce(user, object)
    else
      _ ->
        {:error, "Could not unrepeat"}
    end
  end

  def favorite(id_or_ap_id, user) do
    with %Activity{} = activity <- get_by_id_or_ap_id(id_or_ap_id),
         false <- activity.data["actor"] == user.ap_id,
         object <- Object.normalize(activity.data["object"]["id"]) do
      ActivityPub.like(user, object)
    else
      _ ->
        {:error, "Could not favorite"}
    end
  end

  def unfavorite(id_or_ap_id, user) do
    with %Activity{} = activity <- get_by_id_or_ap_id(id_or_ap_id),
         false <- activity.data["actor"] == user.ap_id,
         object <- Object.normalize(activity.data["object"]["id"]) do
      ActivityPub.unlike(user, object)
    else
      _ ->
        {:error, "Could not unfavorite"}
    end
  end

  def get_visibility(%{"visibility" => visibility})
      when visibility in ~w{public unlisted private direct},
      do: visibility

  def get_visibility(%{"in_reply_to_status_id" => status_id}) when not is_nil(status_id) do
    case get_replied_to_activity(status_id) do
      nil ->
        "public"

      inReplyTo ->
        mastodon_get_visibility(inReplyTo.data["object"])
    end
  end

  def get_visibility(_), do: "public"

  def mastodon_get_visibility(object) do
    public = "https://www.w3.org/ns/activitystreams#Public"
    to = object["to"] || []
    cc = object["cc"] || []

    cond do
      public in to ->
        "public"

      public in cc ->
        "unlisted"

      # this should use the sql for the object's activity
      Enum.any?(to, &String.contains?(&1, "/followers")) ->
        "private"

      true ->
        "direct"
    end
  end

  @instance Application.get_env(:moodle_net, :instance)
  @limit Keyword.get(@instance, :limit)
  def post(user, %{"status" => status} = data) do
    visibility = get_visibility(data)

    with status <- String.trim(status),
         length when length in 1..@limit <- String.length(status),
         attachments <- attachments_from_ids(data["media_ids"]),
         mentions <- Formatter.parse_mentions(status),
         inReplyTo <- get_replied_to_activity(data["in_reply_to_status_id"]),
         {to, cc} <- to_for_user_and_mentions(user, mentions, inReplyTo, visibility),
         tags <- Formatter.parse_tags(status, data),
         content_html <-
           make_content_html(status, mentions, attachments, tags, data["no_attachment_links"]),
         context <- make_context(inReplyTo),
         cw <- data["spoiler_text"],
         object <-
           make_note_data(
             user.ap_id,
             to,
             context,
             content_html,
             attachments,
             inReplyTo,
             tags,
             cw,
             cc
           ),
         object <-
           Map.put(
             object,
             "emoji",
             Formatter.get_emoji(status)
             |> Enum.reduce(%{}, fn {name, file}, acc ->
               Map.put(acc, name, "#{MoodleNetWeb.Endpoint.static_url()}#{file}")
             end)
           ) do
      res =
        ActivityPub.create(%{
          to: to,
          actor: user,
          context: context,
          object: object,
          additional: %{"cc" => cc}
        })

      res
    end
  end

  def update(user) do
    user =
      with emoji <- emoji_from_profile(user),
           source_data <- (user.info["source_data"] || %{}) |> Map.put("tag", emoji),
           new_info <- Map.put(user.info, "source_data", source_data),
           change <- User.info_changeset(user, %{info: new_info}),
           {:ok, user} <- User.update_and_set_cache(change) do
        user
      else
        _e ->
          user
      end

    ActivityPub.update(%{
      local: true,
      to: [user.follower_address],
      cc: [],
      actor: user.ap_id,
      object: ActivityPub.UserView.render("user.json", %{user: user})
    })
  end

  # This is a hack for twidere.
  defp get_by_id_or_ap_id(id) do
    activity = Repo.get(Activity, id) || Activity.get_create_activity_by_object_ap_id(id)

    activity &&
      if activity.data["type"] == "Create" do
        activity
      else
        Activity.get_create_activity_by_object_ap_id(activity.data["object"])
      end
  end

  defp get_replied_to_activity(id) when not is_nil(id) do
    Repo.get(Activity, id)
  end

  defp get_replied_to_activity(_), do: nil

  defp attachments_from_ids(ids) do
    Enum.map(ids || [], fn media_id ->
      Repo.get(Object, media_id).data
    end)
  end

  defp to_for_user_and_mentions(user, mentions, inReplyTo, "public") do
    to = ["https://www.w3.org/ns/activitystreams#Public"]

    mentioned_users = Enum.map(mentions, fn {_, %{ap_id: ap_id}} -> ap_id end)
    cc = [user.follower_address | mentioned_users]

    if inReplyTo do
      {to, Enum.uniq([inReplyTo.data["actor"] | cc])}
    else
      {to, cc}
    end
  end

  defp to_for_user_and_mentions(user, mentions, inReplyTo, "unlisted") do
    {to, cc} = to_for_user_and_mentions(user, mentions, inReplyTo, "public")
    {cc, to}
  end

  defp to_for_user_and_mentions(user, mentions, inReplyTo, "private") do
    {to, cc} = to_for_user_and_mentions(user, mentions, inReplyTo, "direct")
    {[user.follower_address | to], cc}
  end

  defp to_for_user_and_mentions(_user, mentions, inReplyTo, "direct") do
    mentioned_users = Enum.map(mentions, fn {_, %{ap_id: ap_id}} -> ap_id end)

    if inReplyTo do
      {Enum.uniq([inReplyTo.data["actor"] | mentioned_users]), []}
    else
      {mentioned_users, []}
    end
  end

  defp make_content_html(status, mentions, attachments, tags, no_attachment_links \\ false) do
    status
    |> format_input(mentions, tags)
    |> maybe_add_attachments(attachments, no_attachment_links)
  end

  defp make_context(%Activity{data: %{"context" => context}}), do: context
  defp make_context(_), do: Utils.generate_context_id()

  defp maybe_add_attachments(text, _attachments, _no_links = true), do: text

  defp maybe_add_attachments(text, attachments, _no_links) do
    add_attachments(text, attachments)
  end

  def add_attachments(text, attachments) do
    attachment_text =
      Enum.map(attachments, fn
        %{"url" => [%{"href" => href} | _]} ->
          name = URI.decode(Path.basename(href))
          "<a href=\"#{href}\" class='attachment'>#{shortname(name)}</a>"

        _ ->
          ""
      end)

    Enum.join([text | attachment_text], "<br>")
  end

  defp format_input(text, mentions, tags) do
    text
    |> Formatter.html_escape()
    |> String.replace(~r/\r?\n/, "<br>")
    |> (&{[], &1}).()
    |> Formatter.add_links()
    |> Formatter.add_user_links(mentions)
    |> Formatter.add_hashtag_links(tags)
    |> Formatter.finalize()
  end

  defp add_tag_links(text, tags) do
    tags =
      tags
      |> Enum.sort_by(fn {tag, _} -> -String.length(tag) end)

    Enum.reduce(tags, text, fn {full, tag}, text ->
      url = "<a href='#{MoodleNetWeb.base_url()}/tag/#{tag}' rel='tag'>##{tag}</a>"
      String.replace(text, full, url)
    end)
  end

  defp make_note_data(
        actor,
        to,
        context,
        content_html,
        attachments,
        inReplyTo,
        tags,
        cw \\ nil,
        cc \\ []
      ) do
    object = %{
      "type" => "Note",
      "to" => to,
      "cc" => cc,
      "content" => content_html,
      "summary" => cw,
      "context" => context,
      "attachment" => attachments,
      "actor" => actor,
      "tag" => tags |> Enum.map(fn {_, tag} -> tag end) |> Enum.uniq()
    }

    if inReplyTo do
      object
      |> Map.put("inReplyTo", inReplyTo.data["object"]["id"])
      |> Map.put("inReplyToStatusId", inReplyTo.id)
    else
      object
    end
  end

  defp format_naive_asctime(date) do
    date |> DateTime.from_naive!("Etc/UTC") |> format_asctime
  end

  defp format_asctime(date) do
    Strftime.strftime!(date, "%a %b %d %H:%M:%S %z %Y")
  end

  defp date_to_asctime(date) do
    with {:ok, date, _offset} <- date |> DateTime.from_iso8601() do
      format_asctime(date)
    else
      _e ->
        ""
    end
  end

  def to_masto_date(%NaiveDateTime{} = date) do
    date
    |> NaiveDateTime.to_iso8601()
    |> String.replace(~r/(\.\d+)?$/, ".000Z", global: false)
  end

  def to_masto_date(date) do
    try do
      date
      |> NaiveDateTime.from_iso8601!()
      |> NaiveDateTime.to_iso8601()
      |> String.replace(~r/(\.\d+)?$/, ".000Z", global: false)
    rescue
      _e -> ""
    end
  end

  defp shortname(name) do
    if String.length(name) < 30 do
      name
    else
      String.slice(name, 0..30) <> "…"
    end
  end

  def confirm_current_password(user, password) do
    with %User{local: true} = db_user <- Repo.get(User, user.id),
         true <- Pbkdf2.checkpw(password, db_user.password_hash) do
      {:ok, db_user}
    else
      _ -> {:error, "Invalid password."}
    end
  end

  def emoji_from_profile(%{info: info} = user) do
    (Formatter.get_emoji(user.bio) ++ Formatter.get_emoji(user.name))
    |> Enum.map(fn {shortcode, url} ->
      %{
        "type" => "Emoji",
        "icon" => %{"type" => "Image", "url" => "#{Endpoint.url()}#{url}"},
        "name" => ":#{shortcode}:"
      }
    end)
  end
end
