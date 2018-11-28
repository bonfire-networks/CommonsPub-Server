defmodule ActivityPub.SQLObjectAspect do
  alias ActivityPub.ObjectAspecto, as: ObjectAspect

  use ActivityPub.SQLAspect,
    aspect: ObjectAspect,
    persistence: {:table, "activity_pub_objects"}

  alias ActivityPub.Entito, as: Entity
  require ActivityPub.Guards, as: APG

  def create(multi, entity) when APG.has_aspect(entity, ObjectAspect) do
    changeset = create_changeset(entity)
    Ecto.Multi.insert(multi, aspect().name(), changeset)
  end

  def create(multi, _entity), do: multi

  def create_changeset(entity) when APG.has_aspect(entity, ObjectAspect) do
    changes = Entity.fields_for(entity, ObjectAspect)
    Ecto.Changeset.change(%__MODULE__{}, changes)
  end
end
