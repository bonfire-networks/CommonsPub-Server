defmodule Taxonomy.Batch do

  use ActivityPubWeb, :controller

  @tags_index_name "taxonomy_tags_tree"

  def batch() do

    Search.Indexing.create_index(@tags_index_name)

    {:ok, tags} = MoodleNet.Repo.query("WITH RECURSIVE taxonomy_tags_tree AS
    (SELECT id, name, parent_tag_id, CAST(name As varchar(1000)) As name_crumbs, summary
    FROM taxonomy_tag
    WHERE parent_tag_id =1
    UNION ALL
    SELECT si.id,si.name,
      si.parent_tag_id,
      CAST(sp.name_crumbs || '->' || si.name As varchar(1000)) As name_crumbs, 
      si.summary
    FROM taxonomy_tag As si
      INNER JOIN taxonomy_tags_tree AS sp
      ON (si.parent_tag_id = sp.id)
    )
    SELECT id, name, name_crumbs, summary
    FROM taxonomy_tags_tree
    ORDER BY name_crumbs;
    ")

    results = []
    for item <- tags.rows do
      # IO.inspect(item)

      [id, name, name_crumbs, summary] = item

      obj = %{ id: id, name: name, name_crumbs: name_crumbs, summary: summary } 
      IO.inspect(obj)

      Search.Indexing.index_object(obj, @tags_index_name)

      # results = results ++ [obj]

    end

    IO.inspect(length(results))
    IO.inspect(results)

    # Search.Indexer.index_objects(results, @tags_index_name)


  end


end
