# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Tag.GraphQL.TagSchema do
  use Absinthe.Schema.Notation

  alias Bonfire.Tag.GraphQL.TagResolver

  object :tag_queries do

    @desc "Get a tag by ID "
    field :tag, :tag do
      arg(:id, :string)
      # arg :find, :category_find
      resolve(&TagResolver.tag/2)
    end
  end

  object :tag_mutations do

    @desc "Create a Tag out of something else. You can also directly use the tag() mutation with a pointer ID instead."
    field :make_tag, :tag do
      arg(:context_id, :string)
      resolve(&TagResolver.make_pointer_tag/2)
    end

    @desc "Tag a thing (using a Pointer) with one or more Tags (or Categories, or even Pointers to anything that can become tag)"
    field :tag, :boolean do
      arg(:thing, non_null(:string))
      arg(:tags, non_null(list_of(:string)))
      resolve(&TagResolver.tag_something/2)
    end

  end


  @desc "A tag could be a category or hashtag or user or community or etc"
  object :tag do
    @desc "The numeric primary key of the tag"
    field(:id, :string)

    field(:prefix, :string)
    field(:facet, :string)

    # field(:name, :string)
    field(:name, :string) do
      resolve(&TagResolver.name/3)
    end

    # field(:summary, :string)
    field(:summary, :string) do
      resolve(&TagResolver.summary/3)
    end

    @desc "The tag object, like a category or community"
    field :context, :any_context do
      resolve(&Bonfire.GraphQL.CommonResolver.context_edge/3)
    end

    @desc "Things that were tagged with this tag"
    field(:things, list_of(:any_context)) do
      resolve(&TagResolver.tagged_things_edges/3)
    end
  end
end
