# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  import MoodleNet.GraphQL.Schema

  alias MoodleNet.{Uploads, Users, Meta}
  alias MoodleNetWeb.GraphQL

  def upload(params, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, actor} <- Users.fetch_actor(user),
         {:ok, parent} <- Meta.find(params.context_id),
         {:ok, upload} <- Uploads.upload(parent, user, params.file, params) do
      {:ok, Uploads.remote_url(upload)}
    end
  end
end
