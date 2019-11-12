# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access do
  @moduledoc """
  The whitelist system allows MoodleNet to operate in a closed signup
  form where only whitelisted emails (or domains for emails) may sign up.
  """
  
  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Accesss.{
    NoAccessError,
    RegisterEmailDomainAccess,
    RegisterEmailAccess,
  }

  @type whitelist :: RegisterEmailDomainAccess.t | RegisterEmailAccess.t

  @spec create_register_email_domain(domain :: binary) :: \
    {:ok, RegisterEmailDomainAccess.t} | {:error, Changeset.t}
  @doc "Permit registration with all emails at the provided domain"
  def create_register_email_domain(domain) do
    %{domain: domain}
    |> RegisterEmailDomainAccess.changeset()
    |> Repo.insert()
  end

  @spec create_register_email(email :: binary) :: \
    {:ok, RegisterEmailAccess.t} | {:error, Changeset.t}
  @doc "Permit registration with the provided email"
  def create_register_email(email) do
    %{email: email}
    |> RegisterEmailAccess.changeset()
    |> Repo.insert()
  end

  @spec list_register_emails() :: [RegisterEmailAccess.t]
  @doc "Retrieve all RegisterEmailAccess in the database"
  def list_register_emails(), do: Repo.all(RegisterEmailAccess)

  @spec list_register_email_domains() :: [RegisterEmailDomainAccess.t]
  @doc "Retrieve all RegisterEmailDomainAccess in the database"
  def list_register_email_domains(), do: Repo.all(RegisterEmailDomainAccess)

  @spec hard_delete(whitelist) :: {:ok, whitelist} | {:error, Changeset.t}
  @doc "Removes a whitelist entry from the database"
  def hard_delete(%RegisterEmailDomainAccess{}=w), do: Common.hard_delete(w)
  def hard_delete(%RegisterEmailAccess{}=w), do: Common.hard_delete(w)

  @spec hard_delete!(whitelist) :: whitelist
  @doc "Removes a whitelist entry from the database or throws DeletionError"
  def hard_delete!(%RegisterEmailDomainAccess{}=w), do: Common.hard_delete!(w)
  def hard_delete!(%RegisterEmailAccess{}=w), do: Common.hard_delete!(w)

  @spec find_register_email(email :: binary()) :: \
    {:ok, RegisterEmailAccess.t} | {:error, NotFoundError.t}
  @doc "Looks up a RegisterEmailAccess by email"
  def find_register_email(email),
    do: find_response(email, Repo.get_by(RegisterEmailAccess, email: email))

  @spec find_register_email_domain(domain :: binary()) :: \
    {:ok, RegisterEmailDomainAccess.t} | {:error, NotFoundError.t}
  @doc "Looks up a RegisterEmailDomainAccess by domain"
  def find_register_email_domain(domain),
    do: find_response(domain, Repo.get_by(RegisterEmailDomainAccess, domain: domain))

  defp find_response(key, nil), do: {:error, NotFoundError.new(key)}
  defp find_response(_, val), do: {:ok, val}

  @spec is_register_whitelisted?(email :: binary()) :: boolean()
  @doc "true if the user's email or the domain of the user's email is whitelisted"
  def is_register_whitelisted?(email) do
    with {:error, _} <- find_register_email(email),
         {:error, _} <- find_register_email_domain(email_domain(email)) do
      false
    else {:ok, _} -> true
    end
  end

  @doc ":ok if the user's email is whitelisted, else error tuple"
  def check_register_whitelist(email) do
    if is_register_whitelisted?(email),
      do: :ok,
      else: {:error, NotAccessedError.new()}
  end

  defp email_domain(email) do
    [_,domain] = String.split(email, "@", parts: 2)
    domain
  end

end
