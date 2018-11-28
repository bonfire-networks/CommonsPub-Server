defmodule ActivityPub.SQLAspect do
  alias ActivityPub.SQLObjectAspect

  def all(), do: [SQLObjectAspect]

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      aspect = Keyword.fetch!(options, :aspect)
      use Ecto.Schema

      def aspect(), do: unquote(aspect)
      case Keyword.fetch!(options, :persistence) do
        {:table, table} ->
          require ActivityPub.SQLAspect
          ActivityPub.SQLAspect.create_table(table, aspect)
      end
    end
  end

  defmacro create_table(table, aspect) do
    quote bind_quoted: [table: table, aspect: aspect] do
      @primary_key {:local_id, :id, autogenerate: true}
      schema table do
        for name <- aspect.__aspect__(:fields) do
          type = aspect.__aspect__(:type, name)

          field(name, type)
        end
      end
    end
  end
end
