defmodule MoodleNet.Tags do
  # @spec tag(User.t, any, map) :: {:ok, Tag.t} | {:error, Changeset.t()}
  # def tag(%User{} = tagger, tagged, fields) do
  #   Repo.transact_with(fn ->
  #     pointer = Meta.find!(tagged.id)

  #     tagger
  #     |> Tag.create_changeset(pointer, fields)
  #     |> Repo.insert()
  #   end)
  # end

  # @spec update_tag(Tag.t(), map) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  # def update_tag(%Tag{} = tag, fields) do
  #   Repo.transact_with(fn ->
  #     tag
  #     |> Tag.update_changeset(fields)
  #     |> Repo.update()
  #   end)
  # end

  # @spec untag(Tag.t()) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  # def untag(%Tag{} = tag), do: soft_delete(tag)
end
