# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation.GraphQL.Resolver do
  alias CommonsPub.Repo

  alias Bonfire.GraphQL
  alias Bonfire.GraphQL.{

    # FetchFields,
    FetchPage,
    # FetchPages,
    ResolveField,
    # ResolvePage,
    ResolvePages,
    ResolveRootPage
  }

  alias Organisation

  alias Organisation.{
    Organisations
    # Queries
  }

  # alias CommonsPub.Resources.Resource
  # alias Bonfire.Common.Enums
  alias Pointers

  ## resolvers

  def organisation(%{organisation_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_organisation,
      context: id,
      info: info
    })
  end

  def organisations(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_organisations,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_organisation(info, id) do
    Organisations.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :default
    )
  end

  def fetch_organisations(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: Organisation.Queries,
      query: Organisation,
      # cursor_fn: Organisations.cursor(:followers),
      page_opts: page_opts,
      base_filters: [user: GraphQL.current_user(info)],
      data_filters: [:default, page: page_opts]
    })
  end

  def organisations_edge(%{id: id}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_organisations_edge,
      context: id,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_organisations_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)

    FetchPage.run(%FetchPage{
      queries: Organisation.Queries,
      query: Organisation,
      # cursor_fn: Organisations.cursor(:followers),
      page_opts: page_opts,
      base_filters: [context: ids, user: user],
      data_filters: [:default, page: [desc: [followers: page_opts]]]
    })
  end

  ## finally the mutations...

  def create_organisation(%{organisation: attrs, context_id: context_id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Bonfire.Common.Pointers.one(id: context_id),
           :ok <- validate_organisation_context(pointer) do
        context = Bonfire.Common.Pointers.follow!(pointer)
        Organisations.create(user, context, attrs)
      end
    end)
  end

  def create_organisation(%{organisation: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        Organisations.create(user, attrs)
      end
    end)
  end

  def update_organisation(%{organisation: changes, organisation_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, organisation} <- organisation(%{organisation_id: id}, info) do
        cond do
          user.local_user.is_instance_admin ->
            Organisations.update(user, organisation, changes)

          organisation.character.creator_id == user.id ->
            Organisations.update(user, organisation, changes)

          true ->
            GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{organisation_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, organisation} <- Organisations.fetch(id) do
  #   #     organisation = Repo.preload(organisation, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       organisation.character.creator_id == actor.id or
  #   #       organisation.character.context.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Organisations.soft_delete(organisation), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

  defp validate_organisation_context(pointer) do
    if Pointers.table(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts do
    Keyword.fetch!(Bonfire.Common.Config.get(Organisation), :valid_contexts)
  end
end
