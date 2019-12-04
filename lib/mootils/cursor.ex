# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Mootils.Cursor do
  @moduledoc """
  A cursor is a 144-bit synthetic identifier permitting efficient pagination

  It consists of a high resolution posixtime and some random input to
  reduce the risk of collision and is represented either as raw bytes
  (144 bits, 18 bytes) or as a Bose64-encoded string (196 bits, 24 bytes)

  Properties:
  * Stable sort (avoids page flapping) until 2554 (not a joke)
  * Time ordered with nanosecond precision where available
  * Negligible risk of collision (2^-40/clock epsilon by birthday paradox)

  Construction:
  
  1. Pack epochnanos at UTC into a big-endian 64 bit unsigned integer
  2. Append 10 bytes of strong randomness (why? sums to 18 bytes, divisible by 3)
  3. Optionally encode via Bose64
  """

  alias Mootils.Bose64

  @doc "Generates a bose64-encoded cursor"
  @spec generate_bose64() :: binary
  def generate_bose64(), do: Bose64.encode(generate_bin())

  @doc "Generates a binary cursor (no encoding)"
  @spec generate_bin() :: binary
  def generate_bin(), do: time() <> salt()

  @doc "Returns the timestamp part of a bose64-encoded cursor"
  @spec time_bose64(bose64 :: binary) :: pos_integer
  def time_bose64(bose64), do: time_bin(Bose64.decode!(bose64))

  @doc "Returns the timestamp part of a binary cursor"
  @spec time_bin(bin :: binary) :: pos_integer
  def time_bin(<<time :: 64, _ :: binary>>), do: time

  # system time as a 64-bit big endian of nanoseconds
  defp time(), do: :binary.encode_unsigned(:erlang.system_time(:nanosecond), :big)

  defp salt(), do: :crypto.strong_rand_bytes(10)

end
