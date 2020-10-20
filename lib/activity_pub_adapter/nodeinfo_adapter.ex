defmodule CommonsPub.NodeinfoAdapter do
  @behaviour Nodeinfo.Adapter
  alias CommonsPub.Config

  def base_url() do
    CommonsPub.Web.Endpoint.url()
  end

  def user_count() do
    {:ok, users} = CommonsPub.Users.many(preset: :character, peer: nil)
    length(users)
  end

  def gather_nodeinfo_data() do
    instance = Application.get_env(:activity_pub, :instance)

    %Nodeinfo{
      app_name: CommonsPub.Application.name() |> String.downcase(),
      app_version: CommonsPub.Application.version(),
      open_registrations: Config.get([CommonsPub.Users, :public_registration]),
      user_count: user_count(),
      node_name: instance[:name],
      node_description: instance[:description],
      federating: instance[:federating],
      app_repository: CommonsPub.Application.repository()
    }
  end
end
