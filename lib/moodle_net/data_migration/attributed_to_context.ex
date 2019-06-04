# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.DataMigration.AttributedToContext do
  alias MoodleNet.Repo
  alias ActivityPub.SQLEntity

  def call() do
    {collection_rel_ids, collection_assocs} =
      assocs("MoodleNet:Collection", "MoodleNet:Community")
      |> split_rels()

    {resource_rel_ids, resource_assocs} =
      assocs("MoodleNet:EducationalResource", "MoodleNet:Collection")
      |> split_rels()

    Repo.transaction(fn ->
      delete_rels(collection_rel_ids)
      insert_rels(collection_assocs)

      delete_rels(resource_rel_ids)
      insert_rels(resource_assocs)
    end)
  end

  defp split_rels(rels) do
    Enum.reduce(rels, {[], []}, fn rel, {ids, assocs} ->
      {id, assoc} = Map.pop(rel, :id)
      {[id | ids], [assoc | assocs]}
    end)
  end

  defp assocs(subject_type, target_type) do
    import Ecto.Query

    ret =
      from(entity in SQLEntity,
        where: fragment("? @> array[?]", entity.type, ^subject_type),
        inner_join: rel in fragment("activity_pub_object_attributed_tos"),
        on: entity.local_id == rel.subject_id,
        inner_join: target in SQLEntity,
        on: rel.target_id == target.local_id,
        where: fragment("? @> array[?]", target.type, ^target_type),
        select: %{id: rel.id, subject_id: rel.subject_id, target_id: rel.target_id}
      )
      |> Repo.all()

    IO.puts(
      "There are #{length(ret)} #{subject_type} entities whose attributed_to has the type #{
        target_type
      }"
    )

    ret
  end

  defp delete_rels(rel_ids) do
    {num, _} = Repo.delete_all(delete_all_query(rel_ids))
    IO.puts("Rels deleted: #{num}")
  end

  defp delete_all_query(ids) do
    import Ecto.Query
    from(rel in "activity_pub_object_attributed_tos", where: rel.id in ^ids)
  end

  defp insert_rels(assocs) do
    {num, _} = Repo.insert_all("activity_pub_object_contexts", assocs)
    IO.puts("Inserted in 'activity_pub_object_contexts': #{num}")
  end
end
