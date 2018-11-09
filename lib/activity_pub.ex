defmodule ActivityPub do
  alias ActivityPub.{IRI, Object}

  alias MoodleNet.Repo

  @doc """
  Returns true if the given argument is a valid ActivityPub IRI,
  otherwise, returns false.

  ## Examples

      iex> ActivityPub.valid_iri?(nil)
      false

      iex> ActivityPub.valid_iri?("https://social.example/")
      false

      iex> ActivityPub.valid_iri?("https://social.example/alyssa/")
      true
  """
  @spec valid_iri?(String.t) :: boolean
  def valid_iri?(iri), do: validate_iri(iri) == :ok

  @doc """
  Verifies the given argument is an ActivityPub valid IRI
  and returns the reason if not.

  ## Examples

      iex> ActivityPub.validate_iri(nil)
      {:error, :not_string}

      iex> ActivityPub.validate_iri("social.example")
      {:error, :invalid_scheme}

      iex> ActivityPub.validate_iri("https://")
      {:error, :invalid_host}

      iex> ActivityPub.validate_iri("https://social.example/")
      {:error, :invalid_path}

      iex> ActivityPub.validate_iri("https://social.example/alyssa")
      :ok
  """
  @spec validate_iri(String.t) :: :ok | {:error, :invalid_scheme} | {:error, :invalid_host} | {:error, :invalid_path} | {:error, :not_string}
  def validate_iri(iri), do: IRI.validate(iri)

  def is_local?(iri) do
    true
  end

  alias ActivityPub.Actor
  alias Ecto.Multi

  def create_actor(multi, params, opts \\ []) do
    key = Keyword.get(opts, :key, :actor)
    pre_key = String.to_atom("_pre_#{key}")

    multi
    |> Multi.insert(pre_key, Actor.create_local_changeset(params))
    |> Multi.run(key, & Actor.set_uris(&2[pre_key]) |> &1.update())
  end

  @doc """
  Returns an object given and ID.

  Options:
    * `:cache` when is `true`, it uses cache to try to get the object.
      This is the first option.
      Default value is `true`.
    * `:database` when is `true`, it uses the database like second option get the object.
      This is the second option, so it is only used when cache is disabled or it couldn't be found.
      Default value is `true`.
    * `:external` when is `true`, it makes a request to an external server to get the object.
      This is the third option, so it is only used when the database is disabled or it couldn't be found.
      Default value is `true`.
  """
  @spec get_object(binary, map | Keyword.t) :: {:ok, Object.t} | {:error, :not_found} | {:error, :invalid_id}
  def get_object(id, opts \\ %{cache: true, database: true, external: true})
  def get_object(id, opts) do
  end

  def create_object(params) do
    Object.changeset(%Object{}, params)
    |> Repo.insert()
  end

  def update_object(%Object{} = object, params) do
    Object.changeset(object, params)
    |> Repo.update()
  end

  # This modules mix different concerns
  # it has functions to create and persist activities
  # but also activitity queries and other external utility functions
  alias MoodleNet.Accounts.User
  alias MoodleNet.{Activity, Repo, Upload, Notification}
  alias ActivityPub.Object
  alias ActivityPub.Transmogrifier
  alias ActivityPubWeb.MRF
  alias MoodleNetWeb.Federator
  import Ecto.Query
  import ActivityPub.Utils
  require Logger

  @httpoison Application.get_env(:moodle_net, :httpoison)

  @instance Application.get_env(:moodle_net, :instance)

  # For Announce activities, we filter the recipients based on following status for any actors
  # that match actual users.  See issue #164 for more information about why this is necessary.
  defp get_recipients(%{"type" => "Announce"} = data) do
    # It seems it does not implement bto and bcc (private)
    # probably because all is "public"
    to = data["to"] || []
    cc = data["cc"] || []
    recipients = to ++ cc
    actor = User.get_cached_by_ap_id(data["actor"])

    recipients
    |> Enum.filter(fn recipient ->
      case User.get_cached_by_ap_id(recipient) do
        nil ->
          true

        user ->
          User.following?(user, actor)
      end
    end)

    {recipients, to, cc}
  end

  defp get_recipients(data) do
    # Again
    # It seems it does not implement bto and bcc (private)
    # probably because all is "public"
    to = data["to"] || []
    cc = data["cc"] || []
    recipients = to ++ cc
    {recipients, to, cc}
  end

  # This is Mastodon/MoodleNet related stuff
  defp check_actor_is_active(actor) do
    if not is_nil(actor) do
      with user <- User.get_cached_by_ap_id(actor),
           # This is not standard
           nil <- user.info["deactivated"] do
        :ok
      else
        _e -> :reject
      end
    else
      :ok
    end
  end

  # Insert, it seems an activity insert only when needed
  # It is called only by the same module in create function,
  # so it should be private function.
  # However, it also used by Test, for this reason it is public.
  # Test should not relayes on "private" functions to work
  # Why in insert is doing the notification thing and the stream,
  # why not in create?
  def insert(map, local \\ true) when is_map(map) do
    # This is really really really confusing.
    # I visited like 10 times this code and I didn't realize until know what is doing.
    # So it is checking if the activity has been already inserted or not.
    # The main path of the function is when the object is not inserted, so it inserts the activity
    # To check it out uses the following line:
    # with nil <- Activity.normalize(map),
    # so what this really means is: find in our database this activity by id
    # if is not found returns nil, so it goes on with the insertion (the main path)
    # if it is found just returns it...
    #
    # Alternative (pseudo code):
    #
    # def insert(map, local \\ true) when is_map(map) do
    #   case Activity.find_local_by_id(map) do
    #     {:ok, activity} -> {:ok, activity}
    #     nil -> do_insert(map)
    # end
    #
    # and in do_insert we go on
    with nil <- Activity.normalize(map),
         map <- lazy_put_activity_defaults(map),
         # This only checks the present, maybe if a message
         # is received with a delay it makes sense to create,
         # because it was before the "deactivation" of the actor
         # Anyway is Mastodon/MoodleNet stuff
         :ok <- check_actor_is_active(map["actor"]),
         {:ok, map} <- MRF.filter(map),
         :ok <- insert_full_object(map) do
      {recipients, _, _} = get_recipients(map)

      # Here the activity's object is saved maybe by id maybe as full object.
      {:ok, activity} =
        Repo.insert(%Activity{
          data: map,
          local: local,
          actor: map["actor"],
          # This is not an ActivityPub standar property so it should be hidden
          recipients: recipients
        })

      # Notification are really a Mastodon/MoodleNet/Twitter thing
      # It mixed with AP stuff
      Notification.create_notifications(activity)
      {:ok, activity}
    else
      %Activity{} = activity -> {:ok, activity}
      error -> {:error, error}
    end
  end

  # Called by:
  #  * CommonAPI so MastodonAPI and TwitterAPI
  #  * By OStatus
  #  * Transmogrifier when handle incoming activitities
  # Not using transactions in the database.
  # So some data can be saved and other not.
  # This produces inconsistent data.
  def create(%{to: to, actor: actor, context: context, object: object} = params) do
    # Not an AP standard field, should be hidden
    # Seems like only has the params cc and sometimes id!
    additional = params[:additional] || %{}
    # only accept false as false value
    # To know if the activity is local or not is done previously (in another place)
    # This is important because only local object, aka generated by this server,
    # should be federated (send to other servers)
    local = !(params[:local] == false)
    published = params[:published]

    # This seems like validation stuff, like remove "invalid" or "extra"
    # fields received by the function. However this breaks absolutely
    # our intentions to make extensible AS.
    # But at the same time, it adds everything given by the additional params,
    # but additional is used just internally, it is not received by external input.
    # It does not use the ecto library, so it feels weird and clunky
    with create_data <-
           make_create_data(
             %{to: to, actor: actor, published: published, context: context, object: object},
             additional
           ),
         # Inserts if not inserted before
         # context could be nil before, but here it is set :S
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(create_data, local),
         :ok <- maybe_federate(activity),
         # This is better doing it in database
         {:ok, _actor} <- User.increase_note_count(actor) do
      {:ok, activity}
    end
  end

  # Creates an accept activity, just for following
  # Called from Twitter, Mastodon and Transmogrifier.
  def accept(%{to: to, actor: actor, object: object} = params) do
    # only accept false as false value
    local = !(params[:local] == false)

    with data <- %{"to" => to, "type" => "Accept", "actor" => actor, "object" => object},
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(data, local),
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    end
  end

  # Creates an reject activity, just for following
  # Called from Twitter, Mastodon (and not in Transmogrifier, a bug here).
  def reject(%{to: to, actor: actor, object: object} = params) do
    # only accept false as false value
    local = !(params[:local] == false)

    with data <- %{"to" => to, "type" => "Reject", "actor" => actor, "object" => object},
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(data, local),
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    end
  end

  # Creates an update activity
  # Used to update the bio, banner, avatar, etc
  # Used only in Transmogrifier
  def update(%{to: to, cc: cc, actor: actor, object: object} = params) do
    # only accept false as false value
    local = !(params[:local] == false)

    with data <- %{
           "to" => to,
           "cc" => cc,
           "type" => "Update",
           "actor" => actor,
           "object" => object
         },
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(data, local),
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    end
  end

  # Creates a like activity
  # Used in transmogrifier
  # TODO: This is weird, maybe we shouldn't check here if we can make the activity.
  def like(
        %User{ap_id: ap_id} = user,
        %Object{data: %{"id" => _}} = object,
        activity_id \\ nil,
        local \\ true
      ) do
    # Functions in utils
    with nil <- get_existing_like(ap_id, object),
         like_data <- make_like_data(user, object, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(like_data, local),
         # very slow operation!
         {:ok, object} <- add_like_to_object(activity, object),
         :ok <- maybe_federate(activity) do
      {:ok, activity, object}
    else
      %Activity{} = activity -> {:ok, activity, object}
      error -> {:error, error}
    end
  end

  # This should be a undo like in activity pub vocabulary
  # In fact it is called when the undo activity is received
  # Used in transmogrifier
  def unlike(
        %User{} = actor,
        %Object{} = object,
        activity_id \\ nil,
        local \\ true
      ) do
    with %Activity{} = like_activity <- get_existing_like(actor.ap_id, object),
         unlike_data <- make_unlike_data(actor, like_activity, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, unlike_activity} <- insert(unlike_data, local),
         # Remove? Maybe a new activity would be more correct
         {:ok, _activity} <- Repo.delete(like_activity),
         # very slow operation!
         {:ok, object} <- remove_like_from_object(like_activity, object),
         :ok <- maybe_federate(unlike_activity) do
      {:ok, unlike_activity, like_activity, object}
    else
      _e -> {:ok, object}
    end
  end

  # AKA retweet, it creates the activity
  def announce(
        %User{ap_id: _} = user,
        %Object{data: %{"id" => _}} = object,
        activity_id \\ nil,
        local \\ true
      ) do
    with true <- is_public?(object),
         announce_data <- make_announce_data(user, object, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(announce_data, local),
         {:ok, object} <- add_announce_to_object(activity, object),
         :ok <- maybe_federate(activity) do
      {:ok, activity, object}
    else
      error -> {:error, error}
    end
  end

  # Undo a retweet activity
  def unannounce(
        %User{} = actor,
        %Object{} = object,
        activity_id \\ nil,
        local \\ true
      ) do
    # Functions defined in utils
    with %Activity{} = announce_activity <- get_existing_announce(actor.ap_id, object),
         unannounce_data <- make_unannounce_data(actor, announce_activity, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, unannounce_activity} <- insert(unannounce_data, local),
         :ok <- maybe_federate(unannounce_activity),
         # I don't see the point of deleting but probably it is needed to work properly
         {:ok, _activity} <- Repo.delete(announce_activity),
         # Really slow operation
         {:ok, object} <- remove_announce_from_object(announce_activity, object) do
      {:ok, unannounce_activity, object}
    else
      _e -> {:ok, object}
    end
  end

  # Creates follow activity
  def follow(follower, followed, activity_id \\ nil, local \\ true) do
    with data <- make_follow_data(follower, followed, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(data, local),
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    end
  end

  # Creates unfollow actiivty
  def unfollow(follower, followed, activity_id \\ nil, local \\ true) do
    with %Activity{} = follow_activity <- fetch_latest_follow(follower, followed),
         {:ok, follow_activity} <- update_follow_state(follow_activity, "cancelled"),
         unfollow_data <- make_unfollow_data(follower, followed, follow_activity, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(unfollow_data, local),
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    end
  end

  # Deletes an message
  def delete(%Object{data: %{"id" => id, "actor" => actor}} = object, local \\ true) do
    user = User.get_cached_by_ap_id(actor)

    data = %{
      "type" => "Delete",
      "actor" => actor,
      "object" => id,
      "to" => [user.follower_address, "https://www.w3.org/ns/activitystreams#Public"]
    }

    with Repo.delete(object),
         # Deletes all activities related to this object
         Repo.delete_all(Activity.all_non_create_by_object_ap_id_q(id)),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(data, local),
         :ok <- maybe_federate(activity),
         {:ok, _actor} <- User.decrease_note_count(user) do
      {:ok, activity}
    end
  end

  # Block activity
  def block(blocker, blocked, activity_id \\ nil, local \\ true) do
    ap_config = Application.get_env(:moodle_net, :activitypub)
    unfollow_blocked = Keyword.get(ap_config, :unfollow_blocked)
    outgoing_blocks = Keyword.get(ap_config, :outgoing_blocks)

    # Unfollow the blocked person
    # I don't see the point to have a configuration about this
    with true <- unfollow_blocked do
      follow_activity = fetch_latest_follow(blocker, blocked)

      if follow_activity do
        unfollow(blocker, blocked, nil, local)
      end
    end

    # This is interesting, should the block activities be federated?
    with true <- outgoing_blocks,
         block_data <- make_block_data(blocker, blocked, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(block_data, local),
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    else
      _e -> {:ok, nil}
    end
  end

  # Unblock actiivty
  def unblock(blocker, blocked, activity_id \\ nil, local \\ true) do
    with %Activity{} = block_activity <- fetch_latest_block(blocker, blocked),
         unblock_data <- make_unblock_data(blocker, blocked, block_activity, activity_id),
         # Same pattern: insert and send to other servers only if it is necessary
         {:ok, activity} <- insert(unblock_data, local),
         # interesting, here does not check the conf, so undo block are always federated :O
         :ok <- maybe_federate(activity) do
      {:ok, activity}
    end
  end

  # Load a conversation. All shares the same context_id
  def fetch_activities_for_context(context, opts \\ %{}) do
    public = ["https://www.w3.org/ns/activitystreams#Public"]

    recipients =
      if opts["user"], do: [opts["user"].ap_id | opts["user"].following] ++ public, else: public

    query = from(activity in Activity)

    query =
      query
      |> restrict_blocked(opts)
      |> restrict_recipients(recipients, opts["user"])

    # No limits or pagination!
    query =
      from(
        activity in query,
        where:
          fragment(
            "?->>'type' = ? and ?->>'context' = ?",
            activity.data,
            "Create",
            activity.data,
            ^context
          ),
        order_by: [desc: :id]
      )

    Repo.all(query)
  end

  # Used often
  # receives a lot of opts to get the exact query
  def fetch_public_activities(opts \\ %{}) do
    q = fetch_activities_query(["https://www.w3.org/ns/activitystreams#Public"], opts)

    q
    |> restrict_unlisted()
    |> Repo.all()
    # This can be done in query time...
    |> Enum.reverse()
  end

  @valid_visibilities ~w[direct unlisted public private]

  # A lot of functions to make the query exactly like it is needed it
  defp restrict_visibility(query, %{visibility: "direct"}) do
    public = "https://www.w3.org/ns/activitystreams#Public"

    from(
      activity in query,
      join: sender in User,
      on: sender.ap_id == activity.actor,
      # Are non-direct statuses with no to/cc possible?
      where:
        fragment(
          "not (? && ?)",
          [^public, sender.follower_address],
          activity.recipients
        )
    )
  end

  defp restrict_visibility(_query, %{visibility: visibility})
       when visibility not in @valid_visibilities do
    Logger.error("Could not restrict visibility to #{visibility}")
  end

  defp restrict_visibility(query, _visibility), do: query

  def fetch_user_activities(user, reading_user, params \\ %{}) do
    params =
      params
      |> Map.put("type", ["Create", "Announce"])
      |> Map.put("actor_id", user.ap_id)
      |> Map.put("whole_db", true)

    recipients =
      if reading_user do
        ["https://www.w3.org/ns/activitystreams#Public"] ++
          [reading_user.ap_id | reading_user.following]
      else
        ["https://www.w3.org/ns/activitystreams#Public"]
      end

    fetch_activities(recipients, params)
    |> Enum.reverse()
  end

  defp restrict_since(query, %{"since_id" => since_id}) do
    from(activity in query, where: activity.id > ^since_id)
  end

  defp restrict_since(query, _), do: query

  defp restrict_tag(query, %{"tag" => tag}) do
    from(
      activity in query,
      where: fragment("? <@ (? #> '{\"object\",\"tag\"}')", ^tag, activity.data)
    )
  end

  defp restrict_tag(query, _), do: query

  defp restrict_to_cc(query, recipients_to, recipients_cc) do
    from(
      activity in query,
      where:
        fragment(
          "(?->'to' \\?| ?) or (?->'cc' \\?| ?)",
          activity.data,
          ^recipients_to,
          activity.data,
          ^recipients_cc
        )
    )
  end

  defp restrict_recipients(query, [], _user), do: query

  defp restrict_recipients(query, recipients, nil) do
    from(activity in query, where: fragment("? && ?", ^recipients, activity.recipients))
  end

  defp restrict_recipients(query, recipients, user) do
    from(
      activity in query,
      where: fragment("? && ?", ^recipients, activity.recipients),
      or_where: activity.actor == ^user.ap_id
    )
  end

  defp restrict_limit(query, %{"limit" => limit}) do
    from(activity in query, limit: ^limit)
  end

  defp restrict_limit(query, _), do: query

  defp restrict_local(query, %{"local_only" => true}) do
    from(activity in query, where: activity.local == true)
  end

  defp restrict_local(query, _), do: query

  defp restrict_max(query, %{"max_id" => max_id}) do
    from(activity in query, where: activity.id < ^max_id)
  end

  defp restrict_max(query, _), do: query

  defp restrict_actor(query, %{"actor_id" => actor_id}) do
    from(activity in query, where: activity.actor == ^actor_id)
  end

  defp restrict_actor(query, _), do: query

  defp restrict_type(query, %{"type" => type}) when is_binary(type) do
    restrict_type(query, %{"type" => [type]})
  end

  defp restrict_type(query, %{"type" => type}) do
    from(activity in query, where: fragment("?->>'type' = ANY(?)", activity.data, ^type))
  end

  defp restrict_type(query, _), do: query

  defp restrict_favorited_by(query, %{"favorited_by" => ap_id}) do
    from(
      activity in query,
      where: fragment("? <@ (? #> '{\"object\",\"likes\"}')", ^ap_id, activity.data)
    )
  end

  defp restrict_favorited_by(query, _), do: query

  defp restrict_media(query, %{"only_media" => val}) when val == "true" or val == "1" do
    from(
      activity in query,
      where: fragment("not (? #> '{\"object\",\"attachment\"}' = ?)", activity.data, ^[])
    )
  end

  defp restrict_media(query, _), do: query

  defp restrict_replies(query, %{"exclude_replies" => val}) when val == "true" or val == "1" do
    from(
      activity in query,
      where: fragment("?->'object'->>'inReplyTo' is null", activity.data)
    )
  end

  defp restrict_replies(query, _), do: query

  # Only search through last 100_000 activities by default
  defp restrict_recent(query, %{"whole_db" => true}), do: query

  defp restrict_recent(query, _) do
    since = (Repo.aggregate(Activity, :max, :id) || 0) - 100_000

    from(activity in query, where: activity.id > ^since)
  end

  # Wow this is a complex query
  defp restrict_blocked(query, %{"blocking_user" => %User{info: info}}) do
    blocks = info["blocks"] || []
    domain_blocks = info["domain_blocks"] || []

    from(
      activity in query,
      where: fragment("not (? = ANY(?))", activity.actor, ^blocks),
      where: fragment("not (?->'to' \\?| ?)", activity.data, ^blocks),
      where: fragment("not (split_part(?, '/', 3) = ANY(?))", activity.actor, ^domain_blocks)
    )
  end

  defp restrict_blocked(query, _), do: query

  defp restrict_unlisted(query) do
    from(
      activity in query,
      where:
        fragment(
          "not (coalesce(?->'cc', '{}'::jsonb) \\?| ?)",
          activity.data,
          ^["https://www.w3.org/ns/activitystreams#Public"]
        )
    )
  end

  def fetch_activities_query(recipients, opts \\ %{}) do
    base_query =
      from(
        activity in Activity,
        limit: 20,
        order_by: [fragment("? desc nulls last", activity.id)]
      )

    base_query
    |> restrict_recipients(recipients, opts["user"])
    |> restrict_tag(opts)
    |> restrict_since(opts)
    |> restrict_local(opts)
    |> restrict_limit(opts)
    |> restrict_max(opts)
    |> restrict_actor(opts)
    |> restrict_type(opts)
    |> restrict_favorited_by(opts)
    |> restrict_recent(opts)
    |> restrict_blocked(opts)
    |> restrict_media(opts)
    |> restrict_visibility(opts)
    |> restrict_replies(opts)
  end

  def fetch_activities(recipients, opts \\ %{}) do
    fetch_activities_query(recipients, opts)
    |> Repo.all()
    |> Enum.reverse()
  end

  def fetch_activities_bounded(recipients_to, recipients_cc, opts \\ %{}) do
    fetch_activities_query([], opts)
    |> restrict_to_cc(recipients_to, recipients_cc)
    |> Repo.all()
    |> Enum.reverse()
  end

  def upload(file) do
    data = Upload.store(file, Application.get_env(:moodle_net, :instance)[:dedupe_media])
    ActivityPub.create_object(data)
  end

  # This function should be in Transmogrifier because it is translating
  # "mastodon user" from AP object
  def user_data_from_user_object(data) do
    avatar =
      data["icon"]["url"] &&
        %{
          "type" => "Image",
          "url" => [%{"href" => data["icon"]["url"]}]
        }

    banner =
      data["image"]["url"] &&
        %{
          "type" => "Image",
          "url" => [%{"href" => data["image"]["url"]}]
        }

    locked = data["manuallyApprovesFollowers"] || false
    data = Transmogrifier.maybe_fix_user_object(data)

    user_data = %{
      ap_id: data["id"],
      info: %{
        "ap_enabled" => true,
        "source_data" => data,
        "banner" => banner,
        "locked" => locked
      },
      avatar: avatar,
      name: data["name"],
      follower_address: data["followers"],
      bio: data["summary"]
    }

    # nickname can be nil because of virtual actors
    user_data =
      if data["preferredUsername"] do
        Map.put(
          user_data,
          :nickname,
          "#{data["preferredUsername"]}@#{URI.parse(data["id"]).host}"
        )
      else
        Map.put(user_data, :nickname, nil)
      end

    {:ok, user_data}
  end

  # Fetch an user from an external server
  def fetch_and_prepare_user_from_ap_id(ap_id) do
    with {:ok, %{status_code: 200, body: body}} <-
           @httpoison.get(ap_id, [Accept: "application/activity+json"], follow_redirect: true),
         {:ok, data} <- Jason.decode(body) do
      user_data_from_user_object(data)
    else
      e -> Logger.error("Could not decode user at fetch #{ap_id}, #{inspect(e)}")
    end
  end

  # Strange code, I don't fully understand it
  def make_user_from_ap_id(ap_id) do
    # This is call is done again in upgrade_user_from_ap_id
    if _user = User.get_by_ap_id(ap_id) do
      Transmogrifier.upgrade_user_from_ap_id(ap_id)
    else
      with {:ok, data} <- fetch_and_prepare_user_from_ap_id(ap_id) do
        User.insert_or_update_user(data)
      else
        e -> {:error, e}
      end
    end
  end

  @quarantined_instances Keyword.get(@instance, :quarantined_instances, [])

  def should_federate?(inbox, public) do
    if public do
      true
    else
      inbox_info = URI.parse(inbox)
      inbox_info.host not in @quarantined_instances
    end
  end

  def publish(actor, activity) do
    followers =
      if actor.follower_address in activity.recipients do
        {:ok, followers} = User.get_followers(actor)
        followers |> Enum.filter(&(!&1.local))
      else
        []
      end

    public = is_public?(activity)

    remote_inboxes =
      (remote_users(activity) ++ followers)
      |> Enum.filter(fn user -> User.ap_enabled?(user) end)
      |> Enum.map(fn %{info: %{"source_data" => data}} ->
        # Using sharedInbox to make less requests!
        (data["endpoints"] && data["endpoints"]["sharedInbox"]) || data["inbox"]
      end)
      |> Enum.uniq()
      |> Enum.filter(fn inbox -> should_federate?(inbox, public) end)

    {:ok, data} = Transmogrifier.prepare_outgoing(activity.data)
    json = Jason.encode!(data)

    Enum.each(remote_inboxes, fn inbox ->
      # This is really calling to publish_one in async way
      Federator.enqueue(:publish_single_ap, %{
        inbox: inbox,
        json: json,
        actor: actor,
        id: activity.data["id"]
      })
    end)
  end

  def remote_users(%{data: %{"to" => to} = data}) do
    to = to ++ (data["cc"] || [])

    to
    |> Enum.map(fn id -> User.get_cached_by_ap_id(id) end)
    |> Enum.filter(fn user -> user && !user.local end)
  end

  # Just sign and send
  def publish_one(%{inbox: inbox, json: json, actor: actor, id: id}) do
    Logger.info("Federating #{id} to #{inbox}")
    host = URI.parse(inbox).host

    digest = "SHA-256=" <> (:crypto.hash(:sha256, json) |> Base.encode64())

    signature =
      MoodleNetWeb.HTTPSignatures.sign(actor, %{
        host: host,
        "content-length": byte_size(json),
        digest: digest
      })

    @httpoison.post(
      inbox,
      json,
      [
        {"Content-Type", "application/activity+json"},
        {"signature", signature},
        {"digest", digest}
      ],
      hackney: [pool: :default]
    )
  end

  # TODO:
  # This will create a Create activity, which we need internally at the moment.
  # BAD: imaginary activities
  def fetch_object_from_id(id) do
    if object = Object.get_cached_by_ap_id(id) do
      {:ok, object}
    else
      Logger.info("Fetching #{id} via AP")

      with true <- String.starts_with?(id, "http"),
           {:ok, %{body: body, status_code: code}} when code in 200..299 <-
             @httpoison.get(
               id,
               [Accept: "application/activity+json"],
               follow_redirect: true,
               timeout: 10000,
               recv_timeout: 20000
             ),
           {:ok, data} <- Jason.decode(body),
           nil <- Object.normalize(data),
           # It is creating imaginary creatied activities
           # Maybe the object is an updated result
           params <- %{
             "type" => "Create",
             "to" => data["to"],
             "cc" => data["cc"],
             "actor" => data["attributedTo"],
             "object" => data
           },
           # This is a validation!
           :ok <- Transmogrifier.contain_origin(id, params),
           # It creates imaginary create activity
           {:ok, activity} <- Transmogrifier.handle_incoming(params) do
        {:ok, Object.normalize(activity.data["object"])}
      else
        object = %Object{} ->
          {:ok, object}
        e -> e
      end
    end
  end

  # Utility functions
  def is_public?(activity) do
    "https://www.w3.org/ns/activitystreams#Public" in (activity.data["to"] ++
                                                         (activity.data["cc"] || []))
  end

  def visible_for_user?(activity, nil) do
    is_public?(activity)
  end

  def visible_for_user?(activity, user) do
    x = [user.ap_id | user.following]
    y = activity.data["to"] ++ (activity.data["cc"] || [])
    visible_for_user?(activity, nil) || Enum.any?(x, &(&1 in y))
  end
end
