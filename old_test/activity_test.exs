defmodule MoodleNet.ActivityTest do
  use MoodleNet.DataCase
  import MoodleNet.Factory

  test "returns an activity by it's AP id" do
    activity = insert(:note_activity)
    found_activity = MoodleNet.Activity.get_by_ap_id(activity.data["id"])

    assert activity == found_activity
  end

  test "returns activities by it's objects AP ids" do
    activity = insert(:note_activity)
    [found_activity] = MoodleNet.Activity.all_by_object_ap_id(activity.data["object"]["id"])

    assert activity == found_activity
  end

  test "returns the activity that created an object" do
    activity = insert(:note_activity)

    found_activity =
      MoodleNet.Activity.get_create_activity_by_object_ap_id(activity.data["object"]["id"])

    assert activity == found_activity
  end
end
