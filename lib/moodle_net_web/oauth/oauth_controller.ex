# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.OAuth.OAuthController do
  @moduledoc """
  OAuth controller
  """
  use MoodleNetWeb, :controller

  alias MoodleNet.{Accounts, OAuth}

  defmodule AuthorizationParams do
    use Ecto.Schema

    embedded_schema do
      field(:email, :string)
      field(:password, :string)
      field(:client_id, :string)
      field(:state, :string)
      field(:redirect_uri, :string)
      field(:redirect_uri_map, :map)
    end

    @keys [:email, :password, :client_id, :redirect_uri, :state]

    def parse(params) do
      Ecto.Changeset.cast(%__MODULE__{}, params, @keys)
      |> Ecto.Changeset.validate_required(@keys -- [:state])
      |> cast_uri_map()
      |> Ecto.Changeset.apply_action(:insert)
    end

    defp cast_uri_map(%{valid?: false} = ch), do: ch

    defp cast_uri_map(ch) do
      ch
      |> Ecto.Changeset.get_field(:redirect_uri)
      |> URI.parse()
      |> case do
        uri = %URI{scheme: "urn", path: "ietf:wg:oauth:2.0:oob"} ->
          Ecto.Changeset.change(ch, redirect_uri_map: uri)

        uri = %URI{scheme: scheme, host: host}
        when scheme in ["https", "http"] and not is_nil(host) ->
          Ecto.Changeset.change(ch, redirect_uri_map: uri)

        _ ->
          Ecto.Changeset.add_error(ch, :redirect_uri, "Invalid redirect uri")
      end
    end
  end

  plug(ScrubParams, "authorization" when action == :create_authorization)

  def create_authorization(conn, params) do
    with {:ok, params} <- AuthorizationParams.parse(params["authorization"]),
         {:ok, user} <- Accounts.authenticate_by_email_and_pass(params.email, params.password),
         app = OAuth.get_app_by!(client_id: params.client_id),
         {:ok, auth} <- OAuth.create_authorization(user.id, app.id) do
      if params.redirect_uri == "urn:ietf:wg:oauth:2.0:oob" do
        render(conn, "results.html", %{auth: auth})
      else
        url = build_redirect_url(params.redirect_uri_map, auth.hash, params.state)
        redirect(conn, external: url)
      end
    end
  end

  defp build_redirect_url(uri, token, state) do
    params = %{code: token}
    params = if state, do: Map.put(params, :state, state), else: params

    new_query =
      (uri.query || "")
      |> URI.decode_query(params)
      |> URI.encode_query()

    uri
    |> Map.put(:query, new_query)
    |> URI.to_string()
  end

  # TODO
  # - proper scope handling
  def token_exchange(conn, %{"grant_type" => "authorization_code"} = params) do
    with {:ok, {client_id, client_secret}} <- fetch_client_credentials(conn, params),
         app = OAuth.get_app_by!(client_id: client_id, client_secret: client_secret),
         fixed_token = remove_padding(params["code"]),
         auth = OAuth.get_auth_by!(hash: fixed_token, app_id: app.id),
         {:ok, token} <- OAuth.exchange_token(app, auth),
         do: render(conn, "token.json", token: token)
  end

  # TODO
  # - investigate a way to verify the user wants to grant read/write/follow once scope handling is done
  def token_exchange(conn, params) do
    with %{"grant_type" => "password", "username" => name, "password" => password} <- params,
         {:ok, {client_id, client_secret}} <- fetch_client_credentials(conn, params),
         app = OAuth.get_app_by!(client_id: client_id, client_secret: client_secret),
         {:ok, user} <- Accounts.authenticate_by_email_and_pass(name, password),
         {:ok, auth} <- OAuth.create_authorization(user.id, app.id),
         {:ok, token} <- OAuth.exchange_token(app, auth),
         do: render(conn, "token.json", token: token)
  end

  # FIXME
  # def token_exchange(
  #       conn,
  #       %{"grant_type" => "password", "name" => name, "password" => password} = params
  #     ) do
  #   params =
  #     params
  #     |> Map.delete("name")
  #     |> Map.put("username", name)

  #   token_exchange(conn, params)
  # end

  plug(MoodleNetWeb.Plugs.ScrubParams, "token" when action == :token_revoke)

  def token_revoke(conn, %{"token" => token} = params) do
    with {:ok, {client_id, client_secret}} <- fetch_client_credentials(conn, params),
         app = OAuth.get_app_by!(client_id: client_id, client_secret: client_secret) do
      # RFC 7009: invalid tokens [in the request] do not cause an error response
      OAuth.revoke_token(token, app.id)
      send_resp(conn, :no_content, "")
    end
  end

  defp remove_padding(token) do
    token
    |> Base.url_decode64!(padding: false)
    |> Base.url_encode64()
  end

  defp fetch_client_credentials(conn, params) do
    fetch_client_credentials_header(conn) || fetch_client_credentials_params(params) ||
      {:error, :client_credentials_not_received}
  end

  defp fetch_client_credentials_header(conn) do
    with ["Basic " <> encoded] <- get_req_header(conn, "authorization"),
         {:ok, decoded} <- Base.decode64(encoded),
         [id, secret] <-
           String.split(decoded, ":")
           |> Enum.map(&URI.decode_www_form/1) do
      {:ok, {id, secret}}
    else
      _ -> nil
    end
  end

  defp fetch_client_credentials_params(%{
         "client_id" => client_id,
         "client_secret" => client_secret
       })
       when not is_nil(client_id) and not is_nil(client_secret),
       do: {:ok, {client_id, client_secret}}

  defp fetch_client_credentials_params(_), do: nil
end
