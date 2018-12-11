defmodule ActivityPub.SQL.CollectionStatementTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub, as: AP
  alias ActivityPub.SQL.CollectionStatement, as: Subject
  test "add/2 works" do
    person_a = Factory.actor()
    person_b = Factory.actor()

    followers = AP.reload(person_a.followers)
    assert followers.total_items == 0

    assert 1 = Subject.add(followers, person_b)
    assert 0 = Subject.add(followers, person_b)

    assert Subject.in?(followers, person_b)
    refute Subject.in?(followers, person_a)

    followers = AP.reload(person_a.followers)
    assert followers.total_items == 1

    assert 1 = Subject.remove(followers, person_b)
    assert 0 = Subject.remove(followers, person_b)

    followers = AP.reload(person_a.followers)
    assert followers.total_items == 0

    refute Subject.in?(person_a.followers, person_b)
  end
end
