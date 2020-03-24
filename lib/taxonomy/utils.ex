defmodule Taxonomy.Utils do

  use ActivityPubWeb, :controller

  def test(conn, _params) do

    s = "I a,m! the bÉst? 1"
    t = string_to_actor_name(s)

    {:ok, tags} = Taxonomy.Tags.many()

    results = []
    for item <- tags do
      IO.inspect(item.label)
      IO.inspect(string_to_actor_name(item.label))
    end

    json(conn,t)

  end

  def string_to_actor_name(str) do
    Regex.replace(~r/[^a-zA-Z0-9]/u, upper_case_first_letter_of_words(str), "")
  end

  defp upper_case_first_letter_of_words(str) do
    words = ~w(#{str})
    Enum.into(words, [], fn(word) -> first_char_to_uppercase(word) end)
    |> to_string
  end

  defp first_char_to_uppercase(word) do
    code_points = String.codepoints(word)
    first = List.first(code_points)
    code_points
    |> List.replace_at(0, String.upcase(first))
    |> to_string
  end

end
