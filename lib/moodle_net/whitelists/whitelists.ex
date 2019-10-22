# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Whitelists do
  @moduledoc """
  The whitelist system allows MoodleNet to operate in a closed signup
  form where only whitelisted emails (or domains for emails) may sign up.
  """
  
  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Whitelists.{
    NotWhitelistedError,
    RegisterEmailDomainWhitelist,
    RegisterEmailWhitelist,
  }

  @type whitelist :: RegisterEmailDomainWhitelist.t | RegisterEmailWhitelist.t

  @spec create_register_email_domain(domain :: binary) :: \
    {:ok, RegisterEmailDomainWhitelist.t} | {:error, Changeset.t}
  @doc "Permit registration with all emails at the provided domain"
  def create_register_email_domain(domain) do
    %{domain: domain}
    |> RegisterEmailDomainWhitelist.changeset()
    |> Repo.insert()
  end

  @spec create_register_email(email :: binary) :: \
    {:ok, RegisterEmailWhitelist.t} | {:error, Changeset.t}
  @doc "Permit registration with the provided email"
  def create_register_email(email) do
    %{email: email}
    |> RegisterEmailWhitelist.changeset()
    |> Repo.insert()
  end

  @spec list_register_emails() :: [RegisterEmailWhitelist.t]
  @doc "Retrieve all RegisterEmailWhitelist in the database"
  def list_register_emails(), do: Repo.all(RegisterEmailWhitelist)

  @spec list_register_email_domains() :: [RegisterEmailDomainWhitelist.t]
  @doc "Retrieve all RegisterEmailDomainWhitelist in the database"
  def list_register_email_domains(), do: Repo.all(RegisterEmailDomainWhitelist)

  @spec hard_delete(whitelist) :: {:ok, whitelist} | {:error, Changeset.t}
  @doc "Removes a whitelist entry from the database"
  def hard_delete(%RegisterEmailDomainWhitelist{}=w), do: Common.hard_delete(w)
  def hard_delete(%RegisterEmailWhitelist{}=w), do: Common.hard_delete(w)

  @spec hard_delete!(whitelist) :: whitelist
  @doc "Removes a whitelist entry from the database or throws DeletionError"
  def hard_delete!(%RegisterEmailDomainWhitelist{}=w), do: Common.hard_delete!(w)
  def hard_delete!(%RegisterEmailWhitelist{}=w), do: Common.hard_delete!(w)

  @spec find_register_email(email :: binary()) :: \
    {:ok, RegisterEmailWhitelist.t} | {:error, NotFoundError.t}
  @doc "Looks up a RegisterEmailWhitelist by email"
  def find_register_email(email),
    do: find_response(email, Repo.get_by(RegisterEmailWhitelist, email: email))

  @spec find_register_email_domain(domain :: binary()) :: \
    {:ok, RegisterEmailDomainWhitelist.t} | {:error, NotFoundError.t}
  @doc "Looks up a RegisterEmailDomainWhitelist by domain"
  def find_register_email_domain(domain),
    do: find_response(domain, Repo.get_by(RegisterEmailDomainWhitelist, domain: domain))

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
      else: {:error, NotWhitelistedError.new()}
  end

  defp email_domain(email) do
    [_,domain] = String.split(email, "@", parts: 2)
    domain
  end

end
