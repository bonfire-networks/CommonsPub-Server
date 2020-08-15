defmodule MoodleNetWeb.Helpers.Common do
  import Phoenix.LiveView
  require Logger

  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.Helpers.{
    # Profiles,
    Account,
    Communities
  }

  alias MoodleNetWeb.GraphQL.LikesResolver

  def strlen(x) when is_nil(x), do: 0
  def strlen(%{} = obj) when obj == %{}, do: 0
  def strlen(%{}), do: 1
  def strlen(x) when is_binary(x), do: String.length(x)
  def strlen(x) when is_list(x), do: length(x)
  def strlen(x) when x > 0, do: 1
  # let's say that 0 is nothing
  def strlen(x) when x == 0, do: 0

  @doc "Returns a value, or a fallback if not present"
  def e(key, fallback) do
    if(strlen(key) > 0) do
      key
    else
      fallback
    end
  end

  @doc "Returns a value from a map, or a fallback if not present"
  def e(map, key, fallback) do
    # IO.inspect(e: map)

    if(is_map(map)) do
      # attempt using key as atom or string
      map_get(map, key, fallback)
    else
      fallback
    end
  end

  @doc "Returns a value from a nested map, or a fallback if not present"
  def e(map, key1, key2, fallback) do
    e(e(map, key1, %{}), key2, fallback)
  end

  def e(map, key1, key2, key3, fallback) do
    e(e(map, key1, key2, %{}), key3, fallback)
  end

  def e(map, key1, key2, key3, key4, fallback) do
    e(e(map, key1, key2, key3, %{}), key4, fallback)
  end

  def is_numeric(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  def to_number(str) do
    case Float.parse(str) do
      {num, ""} -> num
      _ -> 0
    end
  end

  def map_get(%Ecto.Association.NotLoaded{} = map, key, fallback) when is_atom(key) do
    IO.inspect("ERROR: cannot get key `#{key}` from an unloaded map:")
    IO.inspect(map)
    fallback
  end

  def map_get(map, %Ecto.Association.NotLoaded{} = key, fallback) do
    IO.inspect("WARNING: cannot get from an unloaded key, trying to preload...")
    map_get(map, maybe_preload(map, key), fallback)
  end

  @doc """
  Attempt geting a value out of a map by atom key, or try with string key, or return a fallback
  """
  def map_get(map, key, fallback) when is_atom(key) do
    Map.get(map, key, map_get(map, Atom.to_string(key), fallback))
  end

  @doc """
  Attempt geting a value out of a map by string key, or try with atom key (if it's an existing atom), or return a fallback
  """
  def map_get(map, key, fallback) when is_binary(key) do
    Map.get(
      map,
      key,
      Map.get(
        map,
        Recase.to_camel(key),
        Map.get(
          map,
          maybe_str_to_atom(key),
          Map.get(
            map,
            maybe_str_to_atom(Recase.to_camel(key)),
            fallback
          )
        )
      )
    )
  end

  def map_get(map, key, fallback) do
    Map.get(map, key, fallback)
  end

  def maybe_str_to_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> str
    end
  end

  def input_to_atoms(data) do
    data |> Map.new(fn {k, v} -> {maybe_str_to_atom(k), v} end)
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  def r(html), do: Phoenix.HTML.raw(html)

  def markdown(html), do: r(markdown_to_html(html))

  def markdown_to_html(nil) do
    nil
  end

  def markdown_to_html(content) do
    content
    |> Earmark.as_html!()
    |> external_links()
  end

  # open outside links in a new tab
  def external_links(content) do
    Regex.replace(~r/(<a href=\"http.+\")>/U, content, "\\1 target=\"_blank\">")
  end

  def date_from_now(date) do
    with {:ok, from_now} <-
           Timex.shift(date, minutes: -3)
           |> Timex.format("{relative}", :relative) do
      from_now
    else
      _ ->
        ""
    end
  end

  def maybe_preload(obj, :context) do
    prepare_context(obj)
  end

  def maybe_preload(obj, preloads) do
    maybe_do_preload(obj, preloads)
  end

  defp maybe_do_preload(obj, preloads) do
    # IO.inspect(maybe_preload_obj: obj)
    # IO.inspect(maybe_preload_preloads: preloads)
    MoodleNet.Repo.preload(obj, preloads)
  rescue
    ArgumentError ->
      IO.inspect(arg_error_preload: preloads)
      # IO.inspect(from_maybe_preload: obj)
      obj

    MatchError ->
      IO.inspect(match_error_preload: preloads)
      # IO.inspect(from_maybe_preload: obj)
      obj

      # Protocol.UndefinedError ->
      #   IO.inspect(protocol_undefined_error_preload: preloads)
      #   IO.inspect(from_maybe_preload: obj)
      #   obj
  end

  @doc """
  This initializes the socket assigns
  """
  def init_assigns(
        _params,
        %{
          "auth_token" => auth_token,
          "current_user" => current_user,
          "_csrf_token" => csrf_token
        } = session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    # Logger.info(session_preloaded: session)
    socket
    |> assign(:auth_token, fn -> auth_token end)
    |> assign(:current_user, fn -> current_user end)
    |> assign(:csrf_token, fn -> csrf_token end)
    |> assign(:static_changed, static_changed?(socket))
    |> assign(:search, "")
  end

  def init_assigns(
        _params,
        %{
          "auth_token" => auth_token,
          "_csrf_token" => csrf_token
        } = session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    # Logger.info(session_load: session)

    current_user = Account.current_user(session["auth_token"])

    # IO.inspect(session_loaded_user: current_user)

    communities_follows =
      if(current_user) do
        Communities.user_communities_follows(current_user, current_user)
      end

    my_communities =
      if(communities_follows) do
        Communities.user_communities(current_user, current_user)
      end

    socket
    |> assign(:csrf_token, csrf_token)
    |> assign(:static_changed, static_changed?(socket))
    |> assign(:auth_token, auth_token)
    |> assign(:show_title, false)
    |> assign(:toggle_post, false)
    |> assign(:toggle_community, false)
    |> assign(:toggle_collection, false)
    |> assign(:toggle_link, false)
    |> assign(:toggle_ad, false)
    |> assign(:current_context, nil)
    |> assign(:current_user, current_user)
    |> assign(:my_communities, my_communities)
    |> assign(:my_communities_page_info, communities_follows.page_info)
    |> assign(:search, "")
  end

  def init_assigns(
        _params,
        %{
          "_csrf_token" => csrf_token
        } = session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    socket
    |> assign(:csrf_token, csrf_token)
    |> assign(:static_changed, static_changed?(socket))
    |> assign(:current_user, nil)
    |> assign(:search, "")
  end

  def init_assigns(_params, _session, %Phoenix.LiveView.Socket{} = socket) do
    socket
    |> assign(:current_user, nil)
    |> assign(:static_changed, static_changed?(socket))
  end

  def contexts_fetch!(ids) do
    with {:ok, ptrs} <-
           MoodleNet.Meta.Pointers.many(id: List.flatten(ids)) do
      MoodleNet.Meta.Pointers.follow!(ptrs)
    end
  end

  def context_fetch(id) do
    with {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: id) do
      MoodleNet.Meta.Pointers.follow!(pointer)
    end
  end

  def prepare_context(thing) do
    if Map.has_key?(thing, :context_id) and !is_nil(thing.context_id) do
      thing = maybe_do_preload(thing, :context)

      # IO.inspect(context_maybe_preloaded: thing)

      context_follow(thing, thing.context)
    else
      if Map.has_key?(thing, :context) do
        context_follow(thing, thing.context)
      else
        thing
      end
    end
  end

  defp context_follow(thing, %Pointers.Pointer{} = pointer) do
    context = MoodleNet.Meta.Pointers.follow!(pointer)

    add_context_type(thing, context)
  end

  defp context_follow(thing, %{id: id} = context) do
    # IO.inspect("already have a loaded object")
    add_context_type(thing, context)
  end

  defp context_follow(%{context_id: nil} = thing, context) do
    add_context_type(thing, context)
  end

  defp context_follow(%{context_id: context_id} = thing, _) do
    {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: context_id)
    context_follow(thing, pointer)
  end

  defp add_context_type(%{context_type: _} = thing, context) do
    thing
    |> Map.merge(%{context: context})
  end

  defp add_context_type(thing, context) do
    type = context_type(context)

    thing
    |> Map.merge(%{context_type: type})
    |> Map.merge(%{context: context})
  end

  def context_type(context) do
    context.__struct__
    |> Module.split()
    |> Enum.at(-1)
    |> String.downcase()
  end

  def image(thing) do
    # gravatar style and size for fallback images
    image(thing, "retro", 50)
  end

  def icon(thing) do
    # gravatar style and size for fallback icons
    icon(thing, "retro", 50)
  end

  def image(parent, style, size) do
    parent =
      if(is_map(parent) and Map.has_key?(parent, :__struct__)) do
        maybe_preload(parent, image: [:content_upload, :content_mirror])
      end

    image_url(parent, :image, style, size)
  end

  def icon(parent, style, size) do
    parent =
      if(is_map(parent) and Map.has_key?(parent, :__struct__)) do
        maybe_preload(parent, icon: [:content_upload, :content_mirror])
      end

    image_url(parent, :icon, style, size)
  end

  defp image_url(parent, field_name, style, size) do
    if(is_map(parent) and Map.has_key?(parent, :__struct__)) do
      # IO.inspect(image_field: field_name)
      # parent = maybe_preload(parent, field_name: [:content_upload, :content_mirror])
      # IO.inspect(image_parent: parent)

      # img = maybe_preload(Map.get(parent, field_name), :content_upload)

      img = e(parent, field_name, :content_upload, :path, nil)

      if(!is_nil(img)) do
        # use uploaded image
        MoodleNet.Uploads.prepend_url(img)
      else
        # otherwise try external image
        # img = maybe_preload(Map.get(parent, field_name), :content_mirror)
        img = e(parent, field_name, :content_mirror, :url, nil)

        if(!is_nil(img)) do
          img
        else
          # or a gravatar
          image_gravatar(e(parent, :id, nil), style, size)
        end
      end
    else
      image_gravatar(field_name, style, size)
    end
  end

  def image_gravatar(seed, style, size) do
    MoodleNet.Users.Gravatar.url(to_string(seed), style, size)
  end

  def content_url(parent) do
    parent =
      if(Map.has_key?(parent, :__struct__)) do
        maybe_preload(parent, content: [:content_upload, :content_mirror])
      end

    url = e(parent, :content, :content_upload, :path, nil)

    if(!is_nil(url)) do
      # use uploaded file
      MoodleNet.Uploads.prepend_url(url)
    else
      # otherwise try external link
      # img = Repo.preload(Map.get(parent, field_name), :content_mirror)
      url = e(parent, :content, :content_mirror, :url, nil)

      if(!is_nil(url)) do
        url
      else
        ""
      end
    end
  end

  def is_liked(current_user, context_id)
      when not is_nil(current_user) and not is_nil(context_id) do
    my_like =
      LikesResolver.fetch_my_like_edge(
        %{
          context: %{current_user: current_user}
        },
        context_id
      )

    # IO.inspect(my_like: my_like)
    is_liked(my_like)
  end

  def is_liked(_, _) do
    false
  end

  defp is_liked(%{data: data}) when data == %{} do
    false
  end

  defp is_liked(%{data: _}) do
    true
  end

  defp is_liked(_) do
    false
  end

  def context_url(%MoodleNet.Communities.Community{
        actor: %{preferred_username: preferred_username}
      })
      when not is_nil(preferred_username) do
    "/&" <> preferred_username
  end

  def context_url(%MoodleNet.Users.User{
        actor: %{preferred_username: preferred_username}
      })
      when not is_nil(preferred_username) do
    "/@" <> preferred_username
  end

  def context_url(%{
        actor: %{preferred_username: preferred_username}
      })
      when not is_nil(preferred_username) do
    "/+" <> preferred_username
  end

  def context_url(%{thread_id: thread_id, id: comment_id, reply_to_id: is_reply})
      when not is_nil(thread_id) and not is_nil(is_reply) do
    "/!" <> thread_id <> "/discuss/" <> comment_id <> "#reply"
  end

  def context_url(%{thread_id: thread_id}) when not is_nil(thread_id) do
    "/!" <> thread_id
  end

  def context_url(%{canonical_url: canonical_url}) when not is_nil(canonical_url) do
    canonical_url
  end

  def context_url(%{actor: %{canonical_url: canonical_url}})
      when not is_nil(canonical_url) do
    canonical_url
  end

  def context_url(%{__struct__: module_name} = activity) do
    IO.inspect(unsupported_by_activity_url: module_name)
    "#unsupported_by_activity_url/" <> to_string(module_name)
  end

  def context_url(activity) do
    IO.inspect(unsupported_by_activity_url: activity)
    "#unsupported_by_activity_url"
  end

  def e_actor_field(obj, field, fallback) do
    e(
      obj,
      field,
      e(
        obj,
        :actor,
        field,
        e(
          obj,
          :character,
          field,
          e(
            obj,
            :character,
            :actor,
            field,
            fallback
          )
        )
      )
    )
  end
end
