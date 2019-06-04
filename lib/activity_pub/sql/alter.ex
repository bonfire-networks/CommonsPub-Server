# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.SQL.Alter do
  @moduledoc """
  _Alter_ allows adding or removing _ActivityPub.Entity_(s) to the associations.

  If the association is a single collection, the operation is applied to the collection items.
  """

  alias MoodleNet.Repo

  alias ActivityPub.SQL.Associations.{BelongsTo, ManyToMany, Collection}

  import ActivityPub.SQL.Common
  alias ActivityPub.SQL.Query

  # FIXME Use multi always
  # def add(Ecto.Multi{} = multi, prefix, subject, relation, target)

  def add(_subject, _relation, []), do: {:ok, 0}
  def add([], _relation, _target), do: {:ok, 0}

  def add(subject, relation, target) when not is_list(subject),
    do: add([subject], relation, target)

  def add(subject, relation, target) when not is_list(target),
    do: add(subject, relation, [target])

  def remove([], _relation, _target), do: {:ok, 0}
  def remove(_subject, _relation, []), do: {:ok, 0}

  def remove(subject, relation, target) when not is_list(subject),
    do: remove([subject], relation, target)

  def remove(subject, relation, target) when not is_list(target),
    do: remove(subject, relation, [target])

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    Enum.map(sql_aspect.__sql_aspect__(:associations), fn
      # FIXME this can be refactored
      %ManyToMany{
        name: name,
        sql_aspect: _sql_aspect,
        table_name: table_name,
        type: _type,
        join_keys: [subject_key, target_key]
      } ->
        def add(subjects, unquote(name), targets) do
          # FIXME
          # verify_aspect!(subjects, unquote(_sql_aspect))
          # verify_aspect!(targets, unquote(_type))
          subject_ids = Enum.map(subjects, &local_id/1)
          target_ids = Enum.map(targets, &local_id/1)

          insert_all(
            unquote_splicing([table_name, subject_key, target_key]),
            subject_ids,
            target_ids
          )
        end

        def remove(subjects, unquote(name), targets) do
          # FIXME
          # verify_aspect!(subjects, unquote(_sql_aspect))
          # verify_aspect!(targets, unquote(_type))
          subject_ids = Enum.map(subjects, &local_id/1)
          target_ids = Enum.map(targets, &local_id/1)

          delete_all(
            unquote_splicing([table_name, subject_key, target_key]),
            subject_ids,
            target_ids
          )
        end

      %Collection{
        name: name,
        sql_aspect: sql_aspect,
        table_name: table_name,
        type: _type,
        join_keys: [subject_key, target_key]
      } ->
        def add(subjects, unquote(name), targets) do
          # FIXME
          # verify_aspect!(subjects, unquote(_sql_aspect))
          # verify_aspect!(targets, unquote(_type))
          subjects = Query.preload_aspect(subjects, unquote(sql_aspect))
          subject_ids = Enum.map(subjects, &local_id(&1[unquote(name)]))
          target_ids = Enum.map(targets, &local_id/1)

          insert_all(
            unquote_splicing([table_name, subject_key, target_key]),
            subject_ids,
            target_ids
          )
        end

        def remove(subjects, unquote(name), targets) do
          # FIXME
          # verify_aspect!(subjects, unquote(_sql_aspect))
          # verify_aspect!(targets, unquote(_type))
          subjects = Query.preload_aspect(subjects, unquote(sql_aspect))
          subject_ids = Enum.map(subjects, &local_id(&1[unquote(name)]))
          target_ids = Enum.map(targets, &local_id/1)

          delete_all(
            unquote_splicing([table_name, subject_key, target_key]),
            subject_ids,
            target_ids
          )
        end

      %BelongsTo{name: name} ->
        def add(_, unquote(name), _) do
          raise Argument, "Cannot add items to a BelongsTo relation"
        end

        def remove(_, unquote(name), _) do
          raise Argument, "Cannot add items to a BelongsTo relation"
        end
    end)
  end

  def add(_, relation, _) do
    raise ArgumentError, "Not a valid relation #{inspect(relation)}"
  end

  def remove(_, relation, _) do
    raise ArgumentError, "Not a valid relation #{inspect(relation)}"
  end

  defp insert_all(table_name, subject_key, target_key, subject_ids, target_ids) do
    data =
      for s_id <- subject_ids,
          t_id <- target_ids,
          do: %{subject_key => s_id, target_key => t_id}

    opts = [on_conflict: :nothing]
    {num, nil} = Repo.insert_all(table_name, data, opts)
    {:ok, num}
  end

  defp delete_all(table_name, subject_key, target_key, subject_ids, target_ids) do
    {number, nil} =
      delete_all_query(
        table_name,
        subject_key,
        target_key,
        subject_ids,
        target_ids
      )
      |> Repo.delete_all()

    {:ok, number}
  end

  defp delete_all_query(table_name, subject_key, target_key, subject_ids, target_ids) do
    import Ecto.Query, only: [from: 2]

    from(rel in table_name,
      where: field(rel, ^subject_key) in ^subject_ids and field(rel, ^target_key) in ^target_ids
    )
  end
end
