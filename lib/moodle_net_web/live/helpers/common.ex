defmodule MoodleNetWeb.Helpers.Common do
  import Phoenix.LiveView
  alias MoodleNetWeb.Helpers.{Profiles}

  @doc "Returns a value, or a fallback if not present"
  def e(key, fallback) do
    if(!is_nil(key)) do
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
        params,
        %{
          "auth_token" => auth_token,
          "current_user" => current_user
        } = session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    IO.inspect(session_preloaded: session)

    socket
    |> assign(:auth_token, fn -> auth_token end)
    |> assign(:current_user, fn -> current_user end)
  end

  def init_assigns(
        params,
        %{
          "auth_token" => auth_token
        } = session,
        %Phoenix.LiveView.Socket{} = socket
      ) do
    IO.inspect(session_load: session)

    current_user =
      with {:ok, session_token} <- MoodleNet.Access.fetch_token_and_user(session["auth_token"]) do
        Profiles.prepare(session_token.user, %{icon: true, actor: true})
      end

    IO.inspect(session_load_user: current_user)

    socket
    |> assign(:auth_token, auth_token)
    |> assign(:current_user, current_user)
  end

  def init_assigns(params, session, %Phoenix.LiveView.Socket{} = socket) do
    socket
  end
end
