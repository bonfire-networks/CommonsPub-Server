# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.File do
  @moduledoc """
  Utilities for working with files.
  """

  @spec has_extension?(binary, [binary]) :: boolean

  @doc """
  Returns true if the given `filepath` contains one of the
  extensions in `allowed_exts`.

  Note that the comparison is case-insensitive.
  """
  def has_extension?(filepath, allowed_exts) do
    Enum.member?(allowed_exts, extension(filepath))
  end

  @spec extension(binary) :: binary

  @doc """
  Return the file extension of the given `filepath` in lowercase.
  """
  def extension(filepath) do
    filepath |> Path.extname |> String.downcase
  end

  @spec basename(binary) :: binary

  @doc """
  Return the base name of a full file path without the extension.

  ## Example

  iex> basename("some/path/file.txt")
  "file"
  """
  def basename(filepath) do
    case extension(filepath) do
      ""  -> Path.basename(filepath)
      ext -> Path.basename(filepath, ext)
    end
  end
end
