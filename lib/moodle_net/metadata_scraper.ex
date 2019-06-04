# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.MetadataScraper do
  def fetch(url) when is_binary(url) do
    with {:ok, data} <- Furlex.unfurl(url, follow_redirect: true) do
      {:ok, format_data(data, url)}
    end
  end

  defp format_data(data, url) do
    %{
      title: title(data),
      summary: summary(data),
      image: image(data, url),
      embed_code: embed_code(data),
      language: language(data),
      author: author(data),
      source: source(data),
      resource_type: resource_type(data)
    }
  end

  defp title(data) do
    (get(data, :facebook, "title") || get(data, :twitter, "title") || get(data, :oembed, "title") ||
       get(data, :html, "title"))
    |> only_first()
  end

  defp summary(data) do
    (get(data, :facebook, "description") || get(data, :twitter, "description") ||
       get(data, :html, "description"))
    |> only_first()
  end

  defp image(data, original_url) do
    (get(data, :facebook, "image") || get(data, :twitter, "image") ||
       get(data, :other, "thumbnail_url"))
    |> only_first()
    |> fix_relative_url(original_url)
  end

  defp embed_code(data) do
    (get(data, :facebook, "video:url") || get(data, :facebook, "audio:url") ||
       get(data, :twitter, "player") || get(data, :oembed, "html") || get(data, :oembed, "url"))
    |> only_first()
  end

  defp language(data) do
    (get(data, :facebook, "locale") || get(data, :other, "language"))
    |> only_first()
  end

  defp author(data) do
    (get(data, :facebook, "article:author") || get(data, :twitter, "creator") ||
       get(data, :oembed, "author_name") || get(data, :other, "author"))
    |> only_first()
  end

  defp source(data) do
    (get(data, :facebook, "site_name") || get(data, :oembed, "provider_name"))
    |> only_first()
  end

  defp resource_type(data) do
    (get(data, :facebook, "type") || get(data, :oembed, "type"))
    |> only_first()
  end

  defp get(data, :facebook, label),
    do: Map.get(data.facebook, "og:#{label}")

  defp get(data, :twitter, label),
    do: Map.get(data.twitter, "twitter:#{label}")

  defp get(%{oembed: nil}, :oembed, _label), do: nil

  defp get(%{oembed: oembed}, :oembed, label),
    do: Map.get(oembed, label)

  defp get(data, :html, label),
    do: Map.get(data.html, label)

  defp get(data, :other, label),
    do: Map.get(data.other, label)

  defp only_first([head | _]), do: head
  defp only_first(arg), do: arg

  defp fix_relative_url("", _), do: nil
  defp fix_relative_url(url, original_url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: nil} -> URI.merge(original_url, url) |> to_string()
      _ -> url
    end
  end
  defp fix_relative_url(nil, _), do: nil
end
