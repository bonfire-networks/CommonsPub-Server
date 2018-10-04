defmodule Pleroma.UserInviteToken do
  # This should be Pleroma.Invitations.Token
  # FIXME No index in token
  # TODO Remove after a long period? 6 months?
  use Ecto.Schema

  import Ecto.Changeset

  alias Pleroma.{User, UserInviteToken, Repo}

  schema "user_invite_tokens" do
    field(:token, :string)
    field(:used, :boolean, default: false)

    timestamps()
  end

  @doc """
  Creates an User invite token

  Would be a good idea to split the changeset and the repo call.
  """
  def create_token do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64()

    token = %UserInviteToken{
      used: false,
      token: token
    }

    Repo.insert(token)
  end

  #Create a `Ecto.Changeset` to set `Pleroma.UserInviteToken` as used.
  def used_changeset(struct) do
    struct
    |> cast(%{}, [])
    |> put_change(:used, true)
  end

  # This can be done in just one query
  # The return value is not used
  # This goes in Pleroma.Invitations public API
  def mark_as_used(token) do
    with %{used: false} = token <- Repo.get_by(UserInviteToken, %{token: token}),
         {:ok, token} <- Repo.update(used_changeset(token)) do
      {:ok, token}
    else
      _e -> {:error, token}
    end
  end
end
