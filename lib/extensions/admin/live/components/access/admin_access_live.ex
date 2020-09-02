defmodule CommonsPub.Web.AdminLive.AdminAccessLive do
  use CommonsPub.Web, :live_component
  alias CommonsPub.Web.GraphQL.{AccessResolver, UsersResolver}
  alias CommonsPub.Web.Helpers.{Profiles, Common}
  import CommonsPub.Web.Helpers.Common

  def update(assigns, socket) do
    {:ok, users} =
      UsersResolver.users(
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    {:ok, invited} =
      AccessResolver.register_email_accesses(
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    {:ok, domains} =
      AccessResolver.register_email_domain_accesses(
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    members = Enum.map(users.edges, &Profiles.prepare(&1, %{icon: true, actor: true}))

    {
      :ok,
      socket
      |> assign(
        invited: invited.edges,
        users: members,
        selected: assigns.selected,
        domains: domains.edges,
        current_user: assigns.current_user
      )
    }
  end

  def handle_event("invite", params, socket) do
    params = input_to_atoms(params)

    invite =
      CommonsPub.Web.GraphQL.AdminResolver.send_invite(params, %{
        context: %{current_user: socket.assigns.current_user}
      })

    # TODO error handling

    {:noreply, socket |> put_flash(:info, "Invite sent!")}
  end

  def handle_event("deactivate-user", %{"id" => id}, socket) do
    delete =
      CommonsPub.Web.GraphQL.AdminResolver.deactivate_user(%{id: id}, %{
        context: %{current_user: socket.assigns.current_user}
      })

    # TODO error handling

    {:noreply, socket |> put_flash(:info, "User deactivated!")}
  end

  def handle_event("delete-invite", %{"id" => id}, socket) do
    invite =
      CommonsPub.Web.GraphQL.AccessResolver.delete_register_email_access(%{id: id}, %{
        context: %{current_user: socket.assigns.current_user}
      })

    # TODO error handling

    {:noreply, socket |> put_flash(:info, "Invite sent!")}
  end

  def handle_event("add-domain", params, socket) do
    params = input_to_atoms(params)

    add =
      CommonsPub.Web.GraphQL.AccessResolver.create_register_email_domain_access(params, %{
        context: %{current_user: socket.assigns.current_user}
      })

    # TODO error handling

    {:noreply, socket |> put_flash(:info, "Added!")}
  end

  def handle_event("remove-domain", %{"id" => id}, socket) do
    invite =
      CommonsPub.Web.GraphQL.AccessResolver.delete_register_email_domain_access(%{id: id}, %{
        context: %{current_user: socket.assigns.current_user}
      })

    # TODO error handling

    {:noreply, socket |> put_flash(:info, "Invite sent!")}
  end
end
