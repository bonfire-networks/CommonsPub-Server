defmodule CommonsPub.Web.LoginLive do
  use CommonsPub.Web, :live_view
  import CommonsPub.Web.Helpers.Common
  alias CommonsPub.Web.LoginForm

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)
    changeset = LoginForm.changeset()

    {:ok,
     socket
     |> assign(
       app_name: CommonsPub.Config.get(:app_name),
       app_icon: CommonsPub.Config.get(:app_icon, "/images/sun_face.png"),
       instance_image: "https://i.ytimg.com/vi/_qzacv8dtb4/maxresdefault.jpg",
       app_summary: CommonsPub.Instance.description(),
       changeset: changeset
     )}
  end

  def handle_event("validate", %{"login_form" => params}, socket) do
    changeset = LoginForm.changeset(params)
    changeset = Map.put(changeset, :action, :insert)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("login", %{"login_form" => params}, socket) do
    changeset = LoginForm.changeset(params)

    case LoginForm.send(changeset, params) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Logged in!")
         |> redirect(to: "/~/?auth_token=" <> session.token)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {nil, message} ->
        {:noreply,
         socket
         |> assign(changeset: LoginForm.changeset(%{}))
         |> put_flash(:error, message)}
    end
  end
end
