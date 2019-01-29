defmodule MoodleNetWeb.GraphQL.MiscSchema do
  use Absinthe.Schema.Notation

  alias MoodleNetWeb.GraphQL.Errors

  object :web_metadata do
    field(:title, :string)
    field(:summary, :string)
    field(:image, :string)
    field(:embed_code, :string)
    field(:language, :string)
    field(:author, :string)
    field(:source, :string)
    field(:resource_type, :string)
  end

  def fetch_web_metadata(%{url: url}, info) do
    with {:ok, _actor} <- current_actor(info) do
      case MoodleNet.MetadataScraper.fetch(url) do
        {:error, _} -> Errors.bad_gateway_error()
        ret -> ret
      end
    end
  end

  # FIXME repeated code from moodlenetschema
  defp current_user(%{context: %{current_user: nil}}), do: Errors.unauthorized_error()
  defp current_user(%{context: %{current_user: user}}), do: {:ok, user}

  defp current_actor(info) do
    case current_user(info) do
      {:ok, user} ->
        {:ok, user.actor}

      ret ->
        ret
    end
  end
end
