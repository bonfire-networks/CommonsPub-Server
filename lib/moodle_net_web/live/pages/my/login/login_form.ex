defmodule  MoodleNetWeb.LoginForm  do
  import Ecto.Changeset

  defstruct  [:login, :password]

  @types %{
    login: :string,
    password: :string
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:login, :password])
    |> validate_required([:login, :password])
    |> validate_length(:login, min: 4, max: 100)
  end

 def send(changeset, %{"login" => login, "password" => password } = _params) do
  case apply_action(changeset, :insert) do
    {:ok, _} ->
      session = MoodleNetWeb.Helpers.Account.create_session(%{login: login, password: password})
      if(is_nil(session)) do
        {:nil, "Incorrect details. Please try again..."}
      else
        {:ok, session}
      end

    {:error, changeset} ->
      {:error, changeset}
  end
 end

end
