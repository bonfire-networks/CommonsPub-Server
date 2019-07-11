# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

# Some code here is taken from https://framagit.org/framasoft/mobilizon
defmodule MoodleNet.MediaProxy.URLBuilder do
  @base64_opts [padding: false]
  @proxy_path "media"

  @moduledoc """
  Handles URL's to be used for proxying media files.
  """

  @doc """
  Encode an external or relative URL so that it is proxying to a local URL instead.
  """
  @spec encode(binary) :: binary
  def encode(""), do: nil
  def encode("/" <> _ = url), do: url
  def encode(url) do
    if String.starts_with?(url, MoodleNetWeb.base_url()) do
      url
    else
      encode_url(url)
    end
  end

  @spec filename(URI.t() | binary) :: binary | nil
  def filename(url_or_path) do
    if path = URI.parse(url_or_path).path, do: Path.basename(path)
  end

  defp encode_url(url) do
    # Must preserve '%2F' for compatibility with S3
    replacement = get_replacement(url, ":2F:")

    base64 =
      url
      |> String.replace("%2F", replacement)
      |> URI.decode()
      |> URI.encode()
      |> String.replace(replacement, "%2F")
      |> Base.url_encode64(@base64_opts)

    sig = :crypto.hmac(:sha, fetch_secret!(), base64)
    sig64 = Base.url_encode64(sig, @base64_opts)

    build_url(sig64, base64, filename(url))
  end

  @doc """
  Attempt to decode a URL back into its original form.

  This can fail if the local secret signature has changed, the link will become
  un-decodable and will return `{:error, :invalid_signature}`.
  """
  @spec decode(binary) :: {:ok, binary} | {:error, term}
  def decode(url) do
    with {:ok, sig64, url64} <- extract_url(URI.parse(url)) do
      decode_url(sig64, url64)
    end
  end

  defp decode_url(sig, url) do
    sig = Base.url_decode64!(sig, @base64_opts)
    local_sig = :crypto.hmac(:sha, fetch_secret!(), url)

    if local_sig == sig do
      {:ok, Base.url_decode64!(url, @base64_opts)}
    else
      {:error, :invalid_signature}
    end
  end

  defp extract_url(%URI{path: nil}), do: {:error, :missing_path}
  defp extract_url(%URI{path: path}) do
    with ["/", @proxy_path, sig64, url64 | _] <- Path.split(path) do
      {:ok, sig64, url64}
    else _ ->
      {:error, :missing_signature}
    end
  end

  defp build_url(sig_base64, url_base64, filename \\ nil) do
    [
      MoodleNetWeb.base_url(),
      @proxy_path,
      sig_base64,
      url_base64,
      filename
    ]
    |> Enum.filter(fn x -> x != nil end)
    # FIXME: not going to work where filepaths are \
    |> Path.join()
  end

  defp get_replacement(url, replacement) do
    if String.contains?(url, replacement) do
      get_replacement(url, replacement <> replacement)
    else
      replacement
    end
  end

  defp fetch_secret! do
    Application.get_env(:moodle_net, MoodleNetWeb.Endpoint)
    |> Keyword.fetch!(:secret_key_base)
  end
end
