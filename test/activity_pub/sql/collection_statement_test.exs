defmodule ActivityPub.SQL.CollectionStatementTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub, as: AP
  alias ActivityPub.SQL.CollectionStatement, as: Subject
  # FIXME split in multiple tests
  test "works" do
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

  test "works with multiple" do
    person_a = Factory.actor()
    person_b = Factory.actor()
    person_c = Factory.actor()
    person_d = Factory.actor()


    followers_a = AP.reload(person_a.followers)
    followers_b = AP.reload(person_b.followers)

    assert followers_a.total_items == 0
    assert followers_b.total_items == 0

    followers = [followers_a, followers_b]
    following = [person_c, person_d]

    assert 4 = Subject.add(followers, following)
    assert 0 = Subject.add(followers, following)

    assert Subject.in?(followers_a, person_c)
    assert Subject.in?(followers_a, person_d)
    assert Subject.in?(followers_b, person_d)
    assert Subject.in?(followers_b, person_d)

    assert AP.reload(followers_a).total_items == 2
    assert AP.reload(followers_b).total_items == 2

    assert 2 = Subject.remove(followers, person_c)
    assert 0 = Subject.remove(followers, person_c)

    refute Subject.in?(followers_a, person_c)
    refute Subject.in?(followers_b, person_c)
    assert Subject.in?(followers_a, person_d)
    assert Subject.in?(followers_b, person_d)

    assert AP.reload(followers_a).total_items == 1
    assert AP.reload(followers_b).total_items == 1

    assert 2 = Subject.remove(followers, person_d)
    assert 0 = Subject.remove(followers, person_d)

    refute Subject.in?(followers_a, person_c)
    refute Subject.in?(followers_a, person_d)
    refute Subject.in?(followers_b, person_d)
    refute Subject.in?(followers_b, person_d)

    assert AP.reload(followers_a).total_items == 0
    assert AP.reload(followers_b).total_items == 0
  end
end
