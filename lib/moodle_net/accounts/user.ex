defmodule MoodleNet.Accounts.User do
  @moduledoc """
  User model
  """
  use Ecto.Schema

  schema "accounts_users" do
    field(:email, :string)
    field(:actor_id, :integer)
    field(:confirmed_at, :utc_datetime)

    field(:actor, :any, virtual: true)

    timestamps()
  end

  def changeset(actor, attrs) do
    actor_id = ActivityPub.Entity.local_id(actor)

    %__MODULE__{}
    |> Ecto.Changeset.cast(attrs, [:email])
    |> Ecto.Changeset.validate_format(:email, ~r/.+\@.+\..+/)
    # |> Ecto.Changeset.put_assoc(:primary_actor, actor)
    |> Ecto.Changeset.change(actor: actor, actor_id: actor_id)
    |> Ecto.Changeset.validate_required([:actor_id, :email])
    |> Ecto.Changeset.unique_constraint(:email)
    |> lower_case_email()
    |> whitelist_email()
  end

  defp lower_case_email(%Ecto.Changeset{valid?: false} = ch), do: ch

  defp lower_case_email(%Ecto.Changeset{} = ch) do
    {_, email} = Ecto.Changeset.fetch_field(ch, :email)
    Ecto.Changeset.change(ch, email: String.downcase(email))
  end

  defp whitelist_email(%Ecto.Changeset{valid?: false} = ch), do: ch

  defp whitelist_email(%Ecto.Changeset{} = ch) do
    {_, email} = Ecto.Changeset.fetch_field(ch, :email)

    if MoodleNet.Accounts.is_email_in_whitelist?(email) do
      ch
    else
      Ecto.Changeset.add_error(ch, :email, "You cannot register with this email address",
        validation: "inclusion"
      )
    end
  end

  def confirm_email_changeset(%__MODULE__{} = user) do
    Ecto.Changeset.change(user, confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

  def name(%__MODULE__{} = user) do
    user = preload_actor(user)
    get_in(user.actor, [:name, "und"]) || user.actor.preferred_username
  end

  def preload_actor(%__MODULE__{actor: nil} = user) do
    actor = ActivityPub.get_by_local_id(user.actor_id, aspect: :actor)
    %{user | actor: actor}
  end

  def preload_actor(%__MODULE__{} = user), do: user
end
