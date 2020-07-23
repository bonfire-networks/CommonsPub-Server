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
  def strlen(x), do: length(x)

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
    if(is_map(map)) do
      Map.get(map, key, fallback)
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
    |> assign(:auth_token, auth_token)
    |> assign(:show_title, false)
    |> assign(:show_communities, false)
    |> assign(:new_post, false)
    |> assign(:new_community, false)
    |> assign(:current_user, current_user)
    |> assign(:my_communities, my_communities)
    |> assign(:my_communities_page_info, communities_follows.page_info)
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
    |> assign(:current_user, nil)
  end

  def init_assigns(_params, _session, %Phoenix.LiveView.Socket{} = socket) do
    socket
    |> assign(:current_user, nil)
  end

  def contexts_fetch!(ids) do
    with {:ok, ptrs} <-
           MoodleNet.Meta.Pointers.many(id: MoodleNetWeb.GraphQL.CommonResolver.flatten(ids)) do
      MoodleNet.Meta.Pointers.follow!(ptrs)
    end
  end

  def prepare_context(thing) do
    if(Map.has_key?(thing, :context_id) and !is_nil(thing.context_id)) do
      MoodleNet.Repo.preload(thing, :context)

      {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: thing.context_id)
      context = MoodleNet.Meta.Pointers.follow!(pointer)

      type =
        context.__struct__
        |> Module.split()
        |> Enum.at(-1)
        |> String.downcase()

      thing
      |> Map.merge(%{context_type: type})
      |> Map.merge(%{context: context})
    else
      thing
    end
  end

  def image(thing) do
    # style and size for images
    image(thing, "retro", 50)
  end

  def icon(thing) do
    # style and size for icons
    icon(thing, "retro", 50)
  end

  def image(parent, style, size) do
    parent =
      if(Map.has_key?(parent, :__struct__)) do
        Repo.preload(parent, image: [:content_upload, :content_mirror])
      else
        parent
      end

    image_url(parent, :image, style, size)
  end

  def icon(parent, style, size) do
    parent =
      if(Map.has_key?(parent, :__struct__)) do
        Repo.preload(parent, icon: [:content_upload, :content_mirror])
      else
        parent
      end

    image_url(parent, :icon, style, size)
  end

  defp image_url(parent, field_name, style, size) do
    if(Map.has_key?(parent, :__struct__)) do
      # IO.inspect(image_field: field_name)
      # parent = Repo.preload(parent, field_name: [:content_upload, :content_mirror])
      # IO.inspect(image_parent: parent)

      # img = Repo.preload(Map.get(parent, field_name), :content_upload)

      img = e(parent, field_name, :content_upload, :path, nil)

      if(!is_nil(img)) do
        # use uploaded image
        MoodleNet.Uploads.prepend_url(img)
      else
        # otherwise try external image
        # img = Repo.preload(Map.get(parent, field_name), :content_mirror)
        img = e(parent, field_name, :content_mirror, :url, nil)

        if(!is_nil(img)) do
          img
        else
          # or a gravatar
          image_gravatar(parent.id, style, size)
        end
      end
    else
      image_gravatar(field_name, style, size)
    end
  end

  def image_gravatar(seed, style, size) do
    MoodleNet.Users.Gravatar.url(to_string(seed), style, size)
  end

  def input_to_atoms(data) do
    data |> Map.new(fn {k, v} -> {maybe_str_to_atom(k), v} end)
  end

  def maybe_str_to_atom(str) do
    try do
      String.to_existing_atom(str)
    rescue
      ArgumentError -> str
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
end
