defmodule DotNotes.ParseException do
  @moduledoc """
  Exception module for any issues which arise when parsing through notation.

  Exposes a couple of functions to make raising easier by providing binary templates.
  """

  # default message when raised
  defexception message: "Unexpected error during parsing!"

  @doc """
  Formats a notation key, current character, and character index into an error
  message.
  """
  @spec format(key :: binary, current :: binary, index :: number) :: message :: binary
  def format(key, current, index) do
    "Unable to parse '#{key}' at character '#{current}', column #{index + 1}!"
  end

  @doc """
  Raises a `DotNotes.ParseException` based on the provided args. These args are
  passed to `format/3` in order to create a message for the Exception.
  """
  @spec raise(key :: binary, current :: binary, index :: number) :: __MODULE__
  def raise(key, current, index) do
    key
    |> format(current, index)
    |> __MODULE__.raise
  end

  @doc """
  Raises a `DotNotes.ParseException` with a custom message.

  This is used simply for convenience.
  """
  @spec raise(msg :: binary) :: __MODULE__
  def raise(msg) do
    raise __MODULE__, message: msg
  end

end
