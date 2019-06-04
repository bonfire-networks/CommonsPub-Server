# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", ActivityPubWeb.RoomChannel

  @doc """
  Socket params are passed from the client and can be used to verify and authenticate a user. After
  verification, you can put default assigns into the socket that will be set for all channels, ie:

  `{:ok, assign(socket, :user_id, verified_user_id)}`

  To deny connection, return `:error`.

  See `Phoenix.Token` documentation for examples in performing token verification on connect.
  """
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @doc """
  Socket id's are topics that allow you to identify all sockets for a given user

  Returning `nil` makes this socket anonymous.
  """
  # Examples:
  # Identify all sockets for a given user:
  #   def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Broadcast a "disconnect" event and terminate all active sockets and channels for a given user:
  #   `ActivityPubWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})`


  def id(_socket), do: nil
end
