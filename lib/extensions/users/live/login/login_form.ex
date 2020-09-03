defmodule MoodleNetWeb.LoginForm do
  import Ecto.Changeset

  defstruct [:login, :password]

  @types %{
    login: :string,
    password: :string
  }

  def changeset(attrs \\ %{}) do
    {%__MODULE__{}, @types}
    |> cast(attrs, [:login, :password])
    |> validate_required([:login, :password])
    |> validate_length(:login, min: 2, max: 100)
  end

  # @spec send(Ecto.Changeset.t(), map) ::
  #         {:error, Ecto.Changeset.t()}
  #         | {nil, <<_::304>>}
  #         | {:ok,
  #            nil
  #            | {:error,
  #               %{
  #                 :__struct__ =>
  #                   Ecto.Changeset
  #                   | MoodleNet.Access.InvalidCredentialError
  #                   | MoodleNet.Access.UserDisabledError
  #                   | MoodleNet.Access.UserEmailNotConfirmedError,
  #                 optional(:action) => atom,
  #                 optional(:changes) => map,
  #                 optional(:code) => any,
  #                 optional(:constraints) => [any],
  #                 optional(:data) => {},
  #                 optional(:empty_values) => any,
  #                 optional(:errors) => [any],
  #                 optional(:filters) => map,
  #                 optional(:message) => any,
  #                 optional(:params) => nil | map,
  #                 optional(:prepare) => [any],
  #                 optional(:repo) => atom,
  #                 optional(:repo_changes) => map,
  #                 optional(:repo_opts) => [any],
  #                 optional(:required) => [any],
  #                 optional(:status) => any,
  #                 optional(:types) => nil | map,
  #                 optional(:valid?) => boolean,
  #                 optional(:validations) => [any]
  #               }}
  #            | %{current_user: MoodleNet.Users.Me.t(), token: any}}
  def send(changeset, %{"login" => login, "password" => password} = _params) do
    case apply_action(changeset, :insert) do
      {:ok, _} ->
        session = MoodleNetWeb.Helpers.Account.create_session(%{login: login, password: password})

        if(is_nil(session)) do
          {nil, "Incorrect details. Please try again..."}
        else
          {:ok, session}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
