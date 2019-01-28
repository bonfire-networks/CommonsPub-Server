defmodule ActivityPub.SQL.AlterTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub, as: AP
  alias ActivityPub.SQL.{Alter, Query}

  test "works with many_to_many relations" do
    person_a = Factory.actor()
    person_b = Factory.actor()

    assert {:ok, 1} = Alter.add(person_a, :attributed_to, person_b)
    assert {:ok, 0} = Alter.add(person_a, :attributed_to, person_b)

    assert Query.has?(person_a, :attributed_to, person_b)
    refute Query.has?(person_a, :attributed_to, person_a)

    assert {:ok, 1} = Alter.remove(person_a, :attributed_to, person_b)
    assert {:ok, 0} = Alter.remove(person_a, :attributed_to, person_b)

    refute Query.has?(person_a, :attributed_to, person_b)
  end

  test "works with multiple many_to_many relations" do
    person_a = Factory.actor()
    person_b = Factory.actor()
    person_c = Factory.actor()
    person_d = Factory.actor()

    subjects = [person_a, person_b]
    targets = [person_c, person_d]

    assert {:ok, 4} = Alter.add(subjects, :attributed_to, targets)
    assert {:ok, 0} = Alter.add(subjects, :attributed_to, targets)

    assert Query.has?(person_a, :attributed_to, person_c)
    assert Query.has?(person_a, :attributed_to, person_d)
    assert Query.has?(person_b, :attributed_to, person_d)
    assert Query.has?(person_b, :attributed_to, person_d)

    assert {:ok, 2} = Alter.remove(subjects, :attributed_to, person_c)
    assert {:ok, 0} = Alter.remove(subjects, :attributed_to, person_c)

    refute Query.has?(person_a, :attributed_to, person_c)
    refute Query.has?(person_b, :attributed_to, person_c)
    assert Query.has?(person_a, :attributed_to, person_d)
    assert Query.has?(person_b, :attributed_to, person_d)

    assert {:ok, 2} = Alter.remove(subjects, :attributed_to, person_d)
    assert {:ok, 0} = Alter.remove(subjects, :attributed_to, person_d)

    refute Query.has?(person_a, :attributed_to, person_c)
    refute Query.has?(person_a, :attributed_to, person_d)
    refute Query.has?(person_b, :attributed_to, person_d)
    refute Query.has?(person_b, :attributed_to, person_d)
  end

  test "works with collection" do
    person_a = Factory.actor()
    person_b = Factory.actor()

    # FIXME autogenerated fields should be read after writes
    followers = AP.reload(person_a.followers)
    assert followers.total_items == 0

    assert {:ok, 1} = Alter.add(person_a, :followers, person_b)
    assert {:ok, 0} = Alter.add(person_a, :followers, person_b)

    assert Query.has?(person_a, :followers, person_b)
    refute Query.has?(person_a, :followers, person_a)

    followers = AP.reload(person_a.followers)
    assert followers.total_items == 1

    assert {:ok, 1} = Alter.remove(person_a, :followers, person_b)
    assert {:ok, 0} = Alter.remove(person_a, :followers, person_b)

    followers = AP.reload(person_a.followers)
    assert followers.total_items == 0

    refute Query.has?(person_a, :followers, person_b)
  end

  test "works with multiple collections" do
    person_a = Factory.actor()
    person_b = Factory.actor()
    person_c = Factory.actor()
    person_d = Factory.actor()

    assert AP.reload(person_a.followers).total_items == 0
    assert AP.reload(person_b.followers).total_items == 0

    followers = [person_a, person_b]
    following = [person_c, person_d]

    assert {:ok, 4} = Alter.add(followers, :followers, following)
    assert {:ok, 0} = Alter.add(followers, :followers, following)

    assert Query.has?(person_a, :followers, person_c)
    assert Query.has?(person_a, :followers, person_d)
    assert Query.has?(person_b, :followers, person_d)
    assert Query.has?(person_b, :followers, person_d)

    assert AP.reload(person_a.followers).total_items == 2
    assert AP.reload(person_b.followers).total_items == 2

    assert {:ok, 2} = Alter.remove(followers, :followers, person_c)
    assert {:ok, 0} = Alter.remove(followers, :followers, person_c)

    refute Query.has?(person_a, :followers, person_c)
    refute Query.has?(person_b, :followers, person_c)
    assert Query.has?(person_a, :followers, person_d)
    assert Query.has?(person_b, :followers, person_d)

    assert AP.reload(person_a.followers).total_items == 1
    assert AP.reload(person_b.followers).total_items == 1

    assert {:ok, 2} = Alter.remove(followers, :followers, person_d)
    assert {:ok, 0} = Alter.remove(followers, :followers, person_d)

    refute Query.has?(person_a, :followers, person_c)
    refute Query.has?(person_a, :followers, person_d)
    refute Query.has?(person_b, :followers, person_d)
    refute Query.has?(person_b, :followers, person_d)

    assert AP.reload(person_a.followers).total_items == 0
    assert AP.reload(person_b.followers).total_items == 0
  end
end