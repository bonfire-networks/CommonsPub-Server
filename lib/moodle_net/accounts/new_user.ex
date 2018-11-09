defmodule MoodleNet.Accounts.NewUser do
  use Ecto.Schema

  alias ActivityPub.Actor
  alias MoodleNet.Accounts.PasswordAuth

  schema "accounts_users" do
    field(:email, :string)
    belongs_to :primary_actor, Actor

    timestamps()
  end

  def changeset(actor_id, attrs) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(attrs, [:email])
    |> Ecto.Changeset.validate_format(:email, ~r/.+\@.+\..+/)
    |> Ecto.Changeset.change(primary_actor_id: actor_id)
    |> Ecto.Changeset.validate_required([:primary_actor_id, :email])
    |> Ecto.Changeset.unique_constraint(:email)
    |> lower_case_email()
  end

  defp lower_case_email(%Ecto.Changeset{valid?: false} = ch), do: ch
  defp lower_case_email(%Ecto.Changeset{} = ch) do
    {_, email} = Ecto.Changeset.fetch_field(ch, :email)
    Ecto.Changeset.change(ch, email: String.downcase(email))
  end
end
