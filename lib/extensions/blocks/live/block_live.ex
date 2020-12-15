defmodule CommonsPub.Web.Component.BlockLive do
  use CommonsPub.Web, :live_component



  def handle_event("block", %{"message" => message} = _args, socket) do
    {:ok, block} =
      CommonsPub.Web.GraphQL.BlocksResolver.create_block(
        %{
          context_id: e(socket.assigns.object, :id, nil),
          message: message
        },
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    IO.inspect(block, label: "BLOCK")

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Blocked")
      # |> assign(community: socket.assigns.comment |> Map.merge(%{is_liked: true}))
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end
end
