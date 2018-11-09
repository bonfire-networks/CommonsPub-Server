defmodule MoodleNet.OAuth.App do
  use Ecto.Schema
  alias Ecto.Changeset

  schema "oauth_apps" do
    field(:client_name, :string)
    # FIXME convert to an array
    field(:redirect_uri, :string)
    # FIXME convert to an array
    field(:scopes, :string)
    field(:website, :string)
    field(:client_id, :string)
    field(:client_secret, :string)

    timestamps()
  end

  def register_changeset(params) do
    %__MODULE__{}
    |> Changeset.cast(params, [:client_name, :client_id, :redirect_uri, :scopes, :website])
    |> Changeset.validate_required([:client_name, :client_id, :redirect_uri])
    |> validate_redirect_uri()
    |> put_secret()
    |> Changeset.unique_constraint(:client_id)
  end

  defp validate_redirect_uri(%{valid: false} = ch), do: ch

  defp validate_redirect_uri(ch) do
    client_id =
      ch
      |> Changeset.get_field(:client_id)
      |> URI.parse()
      |> Map.take([:host, :port, :scheme, :userinfo])

    redirect_uri =
      ch
      |> Changeset.get_field(:redirect_uri)
      |> URI.parse()
      |> Map.take([:host, :port, :scheme, :userinfo])

    if client_id == redirect_uri do
      ch
    else
      Changeset.add_error(
        ch,
        :redirect_uri,
        "must have the same scheme, host and port that client_id"
      )
    end
  end

  defp put_secret(%{valid?: false} = ch), do: ch
  defp put_secret(ch), do: Changeset.put_change(ch, :client_secret, MoodleNet.Token.random_key())
end
