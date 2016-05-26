defmodule DotNotes.Keys do
  @moduledoc """
  Module containing key parsing actions for DotNotes.

  This is easily the most complicated part of DotNotes and backs almost every
  action available in the main interface. All key parsing is done via recursive
  actions using Regex matching. Certain places use pattern matching where possible
  for the performance benefits.
  """

  # add some aliases
  alias DotNotes.ParseException, as: PEx
  alias DotNotes.Pattern

  @doc """
  Parses a dot notation binary into a list of keys.

  Array style keys are transformed into numbers, any others into binary. We do
  this using an internal recursion on the input. We prepend any new keys to the
  list and then reverse the list at the end to maintain order.
  """
  @spec execute(position :: number, input :: binary, keys :: [ binary ]) :: keys :: [ binary ]
  def execute(_position, "", keys) do
    Enum.reverse(keys)
  end
  def execute(position, input, keys) do
    prop = find_segment(position, input)
    plen = byte_size(prop)
    ilen = byte_size(input)
    rem  = parse_remainder(prop, plen, input, ilen, position)
    drem = shift_dots(rem)
    rlen = byte_size(drem)
    key  = parse_key(prop)
    npos = position + (ilen - rlen)

    execute(npos, drem, [ key | keys ])
  end

  # Finds a possible segment remaining inside the remaining input. If the input
  # does not contain a valid segment, we raise an error at the current position.
  # Otherwise we return the found segment for further processing.
  defp find_segment(position, input) do
    case Pattern.first_match(input, :segment) do
      nil ->
        PEx.raise(input, String.at(input, 0), position)
      prop ->
        prop
    end
  end

  # Parses a key from a segment. A segment is guaranteed to contain a property
  # so we check for accessors, indexes and properties. The order we check is
  # optimized to account for those most frequently occurring. Once the key is
  # found we return it. Any array based keys will be parsed as integers.
  defp parse_key(prop) do
    cond do
      Pattern.matches?(prop, :accessor) ->
        prop
      Pattern.matches?(prop, :index) ->
        prop
        |> Pattern.first_match(:index)
        |> Integer.parse
        |> Kernel.elem(0)
      true ->
        prop
        |> Pattern.first_match(:property)
    end
  end

  # Parses out the remainder of the notation. This is necessary to account for
  # things like hitting the end of the valid notation, or finding any errors when
  # keys are improperly formed. The remaining input is returned when found.
  defp parse_remainder(_prop, len, _input, len, _position) do
    ""
  end
  defp parse_remainder(_prop, plen, input, _ilen, position) do
    << _ :: binary-size(plen), tail :: binary >> = input

    if byte_size(tail) > 1 do
      << _ :: binary-size(1), next_char :: binary-size(1), _rest :: binary >> = tail

      if verify_next_char(next_char, tail) do
        tail
      else
        PEx.raise(input, next_char, position + plen + 1)
      end
    else
      PEx.raise(trailing_err(tail))
    end
  end

  # This function simply shifts the remainder when led with a trailing `.` to
  # cut off the dot as it's no longer needed.
  defp shift_dots(<< ".", remainder :: binary >>) do
    remainder
  end
  defp shift_dots(remainder) do
    remainder
  end

  # Creates an error message for a trailing special character using the function
  # head to pattern match away any internal branching.
  defp trailing_err(<< ".", _rest :: binary >>) do
    "Unable to parse key with trailing dot!"
  end
  defp trailing_err(_tail) do
    "Unable to parse key with trailing bracket!"
  end

  # Verifies the next character following a successful segment to determine if
  # it's plausible to keep parsing. If the tail starts with a dot, then the next
  # character needs to be an accessor, otherwise it needs to be some form of key
  # opener (either an array index, or a special form key).
  defp verify_next_char(char, << ".", _rest :: binary >>) do
    Pattern.matches?(char, :accessor)
  end
  defp verify_next_char(char, _tail) do
    Pattern.matches?(char, :opener)
  end

end
