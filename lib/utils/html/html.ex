defmodule CommonsPub.HTML do
  alias MoodleNet.Config

  alias CommonsPub.HTML.Formatter

  def truncate(text, max_length \\ 200, omission \\ "...") do
    # Remove trailing whitespace
    text = Regex.replace(~r/([^ \t\r\n])([ \t]+$)/u, text, "\\g{1}")

    if String.length(text) < max_length do
      text
    else
      length_with_omission = max_length - String.length(omission)
      String.slice(text, 0, length_with_omission) <> omission
    end
  end

  def make_content_html(
        status,
        data
      ) do
    content_type = get_content_type(data[:content_type])

    options = []

    status
    |> format_input(content_type, options)
    # |> maybe_add_attachments(attachments, attachment_links)
    |> maybe_add_nsfw_tag(data)
  end

  defp get_content_type(content_type) do
    if Enum.member?(Config.get([:instance, :allowed_post_formats]), content_type) do
      content_type
    else
      "text/plain"
    end
  end

  def format_input(text, format \\ "text/plain", options \\ [])

  @doc """
  Formatting text to plain text.
  """
  def format_input(text, "text/plain", options) do
    text
    |> Formatter.html_escape("text/plain")
    |> String.replace("&amp;", "&")
    |> IO.inspect()
    |> Formatter.linkify(options)
    |> (fn {text, mentions, tags} ->
          {String.replace(text, ~r/\r?\n/, "<br>"), mentions, tags}
        end).()
  end

  @doc """
  Formatting text to html.
  """
  def format_input(text, "text/html", options) do
    text
    |> Formatter.html_escape("text/html")
    |> Formatter.linkify(options)
  end

  @doc """
  Formatting text to markdown.
  """
  def format_input(text, "text/markdown", options) do
    text
    |> Formatter.mentions_escape(options)
    |> Earmark.as_html()
    |> Formatter.linkify(options)
    |> Formatter.html_escape("text/html")
  end

  defp maybe_add_nsfw_tag({text, mentions, tags}, %{"sensitive" => sensitive})
       when sensitive in [true, "True", "true", "1"] do
    {text, mentions, [{"#nsfw", "nsfw"} | tags]}
  end

  defp maybe_add_nsfw_tag(data, _), do: data
end
