# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Plugs.SetLocale do
  @moduledoc """
  Sets the back-end locale by checking the `accept-language` header or a param
  """

  @locales Gettext.known_locales(MoodleNetWeb.Gettext)

  def init(_opts), do: nil

  def call(conn, _) do
    (locale_from_params(conn) || locale_from_header(conn))
    |> set_locale()

    conn
  end

  defp set_locale(nil), do: nil
  defp set_locale(locale), do: Gettext.put_locale(locale)

  defp locale_from_params(conn) do
    conn.params["locale"] |> validate_locale()
  end

  defp validate_locale(locale) when locale in @locales, do: locale

  defp validate_locale(_locale), do: nil

  @doc """
  Taken from set_locale plug written by Gerard de Brieder: https://github.com/smeevil/set_locale/blob/fd35624e25d79d61e70742e42ade955e5ff857b8/lib/headers.ex
  """
  defp locale_from_header(conn) do
    conn
    |> extract_accept_language()
    |> Enum.find(nil, fn accepted_locale -> Enum.member?(@locales, accepted_locale) end)
  end

  def extract_accept_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> ensure_language_fallbacks()

      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp ensure_language_fallbacks(tags) do
    Enum.flat_map(tags, fn tag ->
      [language | _] = String.split(tag, "-")
      if Enum.member?(tags, language), do: [tag], else: [tag, language]
    end)
  end
end
