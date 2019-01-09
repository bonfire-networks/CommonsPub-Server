defmodule MoodleNet.Accounts.PasswordAuth do
  use Ecto.Schema

  schema "accounts_password_auths" do
    belongs_to :user, MoodleNet.Accounts.User
    field(:password_hash, :string)
    field(:password, :string, virtual: true)

    timestamps()
  end

  import Ecto.Changeset

  def create_changeset(user_id, password) do
    attrs = %{password: password}
    %__MODULE__{}
    |> cast(attrs, [:password])
    |> change(user_id: user_id)
    |> foreign_key_constraint(:user_id)
    |> validate_required([:password, :user_id])
    |> validate_length(:password, min: 6)
    |> hash()
  end

  defp hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Comeonin.Pbkdf2.hashpwsalt(password))
  end

  defp hash(changeset) do
    changeset
  end
end
