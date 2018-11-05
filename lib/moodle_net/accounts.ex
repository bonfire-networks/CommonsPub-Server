defmodule MoodleNet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  # import Ecto.Query, warn: false
  alias MoodleNet.Repo

  alias MoodleNet.Accounts.User


  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
