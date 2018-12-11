defmodule ActivityPub.SQL.CollectionStatementTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub, as: AP
  alias ActivityPub.SQL.CollectionStatement, as: Subject
  test "add/2 works" do
    person_a = Factory.actor()
    person_b = Factory.actor()

    assert 1 = Subject.add(person_a.followers, person_b)
    assert 0 = Subject.add(person_a.followers, person_b)

    assert Subject.in?(person_a.followers, person_b)
    refute Subject.in?(person_a.followers, person_a)

    assert 1 = Subject.remove(person_a.followers, person_b)
    assert 0 = Subject.remove(person_a.followers, person_b)

    refute Subject.in?(person_a.followers, person_b)
  end
end
