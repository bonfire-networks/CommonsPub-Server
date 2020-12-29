# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Tag.GraphQL.TagSchema do
  use Absinthe.Schema.Notation

  alias Bonfire.Tag.GraphQL.TagResolver

  object :tag_queries do

    @desc "Get a taggable by ID "
    field :taggable, :taggable do
      arg(:id, :string)
      # arg :find, :category_find
      resolve(&TagResolver.taggable/2)
    end
  end

  object :tag_mutations do

    @desc "Create a Taggable out of something else. You can also directly use the tag() mutation with a pointer ID instead."
    field :make_taggable, :taggable do
      arg(:context_id, :string)
      resolve(&TagResolver.make_pointer_taggable/2)
    end

    @desc "Tag a thing (using a Pointer) with one or more Taggables (or Categories, or even Pointers to anything that can become taggable)"
    field :tag, :boolean do
      arg(:thing, non_null(:string))
      arg(:taggables, non_null(list_of(:string)))
      resolve(&TagResolver.thing_attach_tags/2)
    end

  end


  @desc "A taggable could be a category or hashtag or user or community or etc"
  object :taggable do
    @desc "The numeric primary key of the taggable"
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

    @desc "The taggable object, like a category or community"
    field :context, :any_context do
      resolve(&Bonfire.GraphQL.CommonResolver.context_edge/3)
    end

    @desc "Things that were tagged with this tag"
    field(:things, list_of(:any_context)) do
      resolve(&TagResolver.tagged_things_edges/3)
    end
  end
end
