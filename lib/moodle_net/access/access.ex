# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access do
  @moduledoc """
  The access system allows MoodleNet to operate in a closed signup
  form where only accessed emails (or domains for emails) may sign up.
  """

  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo, Meta}
  alias MoodleNet.Common.NotFoundError

  alias MoodleNet.Access.{
    NoAccessError,
    RegisterEmailAccess,
    RegisterEmailDomainAccess
  }

  @type access :: RegisterEmailDomainAccess.t() | RegisterEmailAccess.t()

  @spec create_register_email_domain(domain :: binary) ::
          {:ok, RegisterEmailDomainAccess.t()} | {:error, Changeset.t()}
  @doc "Permit registration with all emails at the provided domain"
  def create_register_email_domain(domain) do
    Repo.transact_with(fn ->
      Meta.point_to!(RegisterEmailDomainAccess)
      |> RegisterEmailDomainAccess.create_changeset(%{domain: domain})
      |> Repo.insert()
    end)
  end

  @spec create_register_email(email :: binary) ::
          {:ok, RegisterEmailAccess.t()} | {:error, Changeset.t()}
  @doc "Permit registration with the provided email"
  def create_register_email(email) do
    Repo.transact_with(fn ->
      Meta.point_to!(RegisterEmailAccess)
      |> RegisterEmailAccess.create_changeset(%{email: email})
      |> Repo.insert()
    end)
  end

  @spec list_register_emails() :: [RegisterEmailAccess.t()]
  @doc "Retrieve all RegisterEmailAccess in the database"
  def list_register_emails(), do: Repo.all(RegisterEmailAccess)

  @spec list_register_email_domains() :: [RegisterEmailDomainAccess.t()]
  @doc "Retrieve all RegisterEmailDomainAccess in the database"
  def list_register_email_domains(), do: Repo.all(RegisterEmailDomainAccess)

  @spec hard_delete(access) :: {:ok, access} | {:error, Changeset.t()}
  @doc "Removes a access entry from the database"
  def hard_delete(%RegisterEmailDomainAccess{} = w), do: Common.hard_delete(w)
  def hard_delete(%RegisterEmailAccess{} = w), do: Common.hard_delete(w)

  @spec hard_delete!(access) :: access
  @doc "Removes a access entry from the database or throws DeletionError"
  def hard_delete!(%RegisterEmailDomainAccess{} = w), do: Common.hard_delete!(w)
  def hard_delete!(%RegisterEmailAccess{} = w), do: Common.hard_delete!(w)

  @spec find_register_email(email :: binary()) ::
          {:ok, RegisterEmailAccess.t()} | {:error, NotFoundError.t()}
  @doc "Looks up a RegisterEmailAccess by email"
  def find_register_email(email),
    do: find_response(email, Repo.get_by(RegisterEmailAccess, email: email))

  @spec find_register_email_domain(domain :: binary()) ::
          {:ok, RegisterEmailDomainAccess.t()} | {:error, NotFoundError.t()}
  @doc "Looks up a RegisterEmailDomainAccess by domain"
  def find_register_email_domain(domain),
    do: find_response(domain, Repo.get_by(RegisterEmailDomainAccess, domain: domain))

  defp find_response(key, nil), do: {:error, NotFoundError.new(key)}
  defp find_response(_, val), do: {:ok, val}

  @spec is_register_accessed?(email :: binary()) :: boolean()
  @doc "true if the user's email or the domain of the user's email is accessed"
  def is_register_accessed?(email) do
    with {:error, _} <- find_register_email(email),
         {:error, _} <- find_register_email_domain(email_domain(email)) do
      false
    else
      {:ok, _} -> true
    end
  end

  @doc ":ok if the user's email is accessed, else error tuple"
  def check_register_access(email) do
    if is_register_accessed?(email),
      do: :ok,
      else: {:error, NotAccessedError.new()}
  end

  defp email_domain(email) do
    [_, domain] = String.split(email, "@", parts: 2)
    domain
  end
end
