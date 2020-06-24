defmodule Taxonomy.Batch do

  use ActivityPubWeb, :controller

  @tags_index_name "taxonomy_tags_tree"

  def batch() do

    Search.Indexing.create_index(@tags_index_name)

    {:ok, tags} = MoodleNet.Repo.query("WITH RECURSIVE taxonomy_tags_tree AS
    (SELECT id, label, parent_tag_id, CAST(label As varchar(1000)) As label_crumbs, description
    FROM taxonomy_tag
    WHERE parent_tag_id =1
    UNION ALL
    SELECT si.id,si.label,
      si.parent_tag_id,
      CAST(sp.label_crumbs || '->' || si.label As varchar(1000)) As label_crumbs, 
      si.description
    FROM taxonomy_tag As si
      INNER JOIN taxonomy_tags_tree AS sp
      ON (si.parent_tag_id = sp.id)
    )
    SELECT id, label, label_crumbs, description
    FROM taxonomy_tags_tree
    ORDER BY label_crumbs;
    ")

    results = []
    for item <- tags.rows do
      # IO.inspect(item)

      [id, label, label_crumbs, description] = item

      obj = %{ id: id, label: label, label_crumbs: label_crumbs, description: description } 
      IO.inspect(obj)

      Search.Indexing.index_object(obj, @tags_index_name)

      # results = results ++ [obj]

    end

    IO.inspect(length(results))
    IO.inspect(results)

    # Search.Indexer.index_objects(results, @tags_index_name)


  end


end
