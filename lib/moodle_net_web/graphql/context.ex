# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Context do
  @moduledoc """
  GraphQL Plug to add current user to the context
  """
  @behaviour Plug
  alias MoodleNet.{
    Activities,
    Collections,
    Comments,
    Common,
    Communities,
    Features,
    Flags,
    Follows,
    Likes,
    Resources,
    Users,
  }

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    ctx = %{
      current_user: conn.assigns[:current_user],
      auth_token: conn.assigns[:auth_token],
    }
    Map.put(ctx, :loader, dataloader(ctx))
  end

  def dataloader(ctx) do
    Dataloader.new(
      get_policy: :return_nil_on_error,
      timeouts: :timer.seconds(10)
    )
    |> Dataloader.add_source(Activities, Activities.data(ctx))
    |> Dataloader.add_source(Collections, Collections.graphql_data(ctx))
    |> Dataloader.add_source(Communities, Communities.graphql_data(ctx))
    |> Dataloader.add_source(Comments, Comments.data(ctx))
    |> Dataloader.add_source(Follows, Follows.data(ctx))
    |> Dataloader.add_source(Flags, Flags.data(ctx))
    |> Dataloader.add_source(Features, Features.data(ctx))
    |> Dataloader.add_source(Likes, Likes.data(ctx))
    |> Dataloader.add_source(Resources, Resources.data(ctx))
    |> Dataloader.add_source(Users, Users.data(ctx))
  end

end
