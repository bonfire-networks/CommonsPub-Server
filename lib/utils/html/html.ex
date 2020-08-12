defmodule CommonsPub.HTML do
  alias MoodleNet.Config

  alias CommonsPub.HTML.Formatter

  @doc """
  For use for things like a bio, where we want links but not to actually trigger mentions.
  """
  def parse_input(text) when is_binary(text) and text != "" do
    text
    |> format_input("text/plain", mentions_format: :full)
    |> elem(0)
  end

  @doc """
  For use for things like a post/comment, to process the content, and get back any @/&/+ mentions and hashtags
  """
  def parse_input_and_tags(
        status,
        content_type \\ "text/plain"
      ) do
    content_type = get_content_type(content_type)

    options = []

    status
    |> format_input(content_type, options)

    # |> maybe_add_attachments(attachments, attachment_links)
    # |> maybe_add_nsfw_tag(data)
  end

  defp get_content_type(content_type) do
    if Enum.member?(
         Config.get([:instance, :allowed_post_formats], [
           "text/plain",
           "text/markdown",
           "text/html"
         ]),
         content_type
       ) do
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
    IO.inspect("html")

    text
    |> Formatter.html_escape("text/html")
    |> String.replace("&amp;", "&")
    |> IO.inspect()
    |> Formatter.linkify(options)
  end

  @doc """
  Formatting text to markdown.
  FIXME
  """
  def format_input(text, "text/markdown", options) do
    text
    # |> Formatter.mentions_escape(options)
    # |> Earmark.as_html()
    # |> elem(1)
    |> String.replace("&amp;", "&")
    |> IO.inspect()
    |> Formatter.linkify(options ++ [content_type: "text/markdown"])
  end

  # defp maybe_add_nsfw_tag({text, mentions, tags}, %{"sensitive" => sensitive})
  #      when sensitive in [true, "True", "true", "1"] do
  #   {text, mentions, [{"#nsfw", "nsfw"} | tags]}
  # end

  # defp maybe_add_nsfw_tag(data, _), do: data

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
end
