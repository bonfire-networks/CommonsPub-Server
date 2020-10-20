defmodule CommonsPub.NodeinfoAdapter do
  @behaviour Nodeinfo.Adapter
  alias CommonsPub.Application
  alias CommonsPub.Config

  def base_url() do
    CommonsPub.Web.Endpoint.url()
  end

  def user_count() do
    {:ok, users} = CommonsPub.Users.many(preset: :actor, peer: nil)
    length(users)
  end

  def gather_nodeinfo_data() do
    %{
      name: Application.name() |> String.downcase(),
      version: Application.version(),
      open_registrations: Config.get([CommonsPub.Users, :public_registration]),
      user_count: user_count(),
      nodeName: Config.get([:instance, :name]),
      nodeDescription: Config.get([:instance, :description]),
      federation: Config.get([:instance, :federating]),
      repository: Application.repository()
    }
  end
end
