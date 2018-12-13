defmodule ActivityPub.SQLObjectAspect do
  alias ActivityPub.ObjectAspect

  use ActivityPub.SQLAspect,
    aspect: ObjectAspect,
    persistence_method: :fields

  # sql_aspect do
  #   persistence_method(:fields)

  #   join_through_assoc(:attachment, table_name: "activity_pub_object_attachments",
  #                      keys: {:subject_id, :target_id})

  #   virtual_col_assoc
  #   assoc(:name, VirtualCollectionAssoc)
  #   assoc(:name, VirtualCollectionAssoc)
  #   # assoc(:attachment, method: {:table, "activity_pub_object_attachments"},
  #   #       keys: {:subject_id, :target_id}
  # end
end
