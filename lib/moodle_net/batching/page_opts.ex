# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching.PageOpts do

  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Batching.PageOpts

  embedded_schema do
    field :limit, :integer
    field :after, :string
    field :before, :string
    field :max_limit, :integer
    field :min_limit, :integer
  end
  
  @full_cast [:limit, :after, :before]
  @limit_cast [:limit]
  @max_limit 100
  @min_limit 1
  @default_limit 25

  def limit_changeset(fields, options \\ %{})
  def limit_changeset(%{}=fields, %{}=opts) do
    %PageOpts{}
    |> Changeset.cast(fields, @limit_cast)
    |> validate_exclusive()
    |> validate_limit(options(opts))
  end

  def full_changeset(fields, options \\ %{})
  def full_changeset(%{}=fields, %{}=opts) do
    %PageOpts{}
    |> Changeset.cast(fields, @full_cast)
    |> validate_limit(options(opts))
  end

  defp options(%{}=opts) do
    opts
    |> Map.put_new(:max_limit, @max_limit)
    |> Map.put_new(:min_limit, @min_limit)
    |> Map.put_new(:default_limit, @default_limit)
  end

  defp validate_limit(changeset, %{max_limit: max, min_limit: min, default_limit: default}) do
    case Changeset.fetch_change(changeset, :limit) do
      {:ok, _} ->
        changeset
        |> Changeset.validate_number(:limit, less_than_or_equal_to: max)
        |> Changeset.validate_number(:limit, greater_than_or_equal_to: min)

      :error -> Changeset.change(changeset, limit: default)
    end
  end

  defp validate_exclusive(changeset) do
    a = Changeset.fetch_change(changeset, :after)
    b = Changeset.fetch_change(changeset, :before)
    case {a, b} do
      {{:ok,_}, {:ok, _}} ->
        Changeset.add_error(changeset, :before, "Must not be used with after")
      _ -> changeset
    end
  end

end
