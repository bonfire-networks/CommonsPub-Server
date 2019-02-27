defmodule MoodleNet.DataMigration.CreateGravatarIcon do
  alias ActivityPub.SQL.{Query, Alter}
  alias MoodleNet.Repo

  def call() do
    actors =
      Query.new()
      |> Query.with_type("Person")
      |> Query.all()
      |> Query.preload_assoc(:icon)
      |> Enum.filter(&(&1.icon == []))

    Repo.transaction(fn ->
      for actor <- actors do
        gravatar = MoodleNet.Gravatar.url(actor["email"])
        {:ok, icon} = ActivityPub.new(type: "Image", url: gravatar)
        {:ok, icon} = ActivityPub.insert(icon)
        Alter.add(actor, :icon, icon)
      end
    end)
  end
end
