defmodule DotNotes.Pattern do
  @moduledoc """
  This module defines various utilities to do with matching Regex patterns. All
  are defined here so that they can be compiled once at compile time and then used
  via common functions.
  """

  # any internal patterns
  @accessor Regex.compile!("^[a-zA-Z_$][a-zA-Z0-9_$]*$")
  @index    Regex.compile!("^\\[([0-9]+)]$")
  @opener   Regex.compile!("^(?:[0-9]|\"|')$")
  @property Regex.compile!("^\\[(?:'|\")(.*)(?:'|\")]$")
  @segment  Regex.compile!("^((?:[a-zA-Z_$][a-zA-Z0-9_$]*)|(?:\\[(?:'.*?(?='])'|\".*?(?=\"])\")])|(?:\\[\\d+]))")
  @key      Regex.compile!(String.slice(inspect(@segment), 3, byte_size(inspect(@segment)) - 4) <> "$")

  # constant args for matches
  @first [ capture: :all_but_first ]

  @doc """
  Retrieves the first match of an internal Regex against a given binary.

  We pull only the first match and unwrap the found value. If no value is found
  then we return a `nil` value.
  """
  @spec first_match(value :: binary, pattern :: atom) :: match :: binary
  def first_match(value, pattern) do
    pattern
    |> normalize
    |> Regex.run(value, @first)
    |> (&(&1 && List.last(&1) || &1)).()
  end

  @doc """
  Determines whether a binary matches an internal Regex.
  """
  @spec matches?(value :: binary, pattern :: atom) :: true | false
  def matches?(value, pattern) do
    pattern
    |> normalize
    |> Regex.match?(value)
  end

  # Converts an atom to the appropriate internal pattern. If there is no matching
  # pattern we let the error occur as there's no way to recover.
  defp normalize(:accessor), do: @accessor
  defp normalize(   :index), do: @index
  defp normalize(  :opener), do: @opener
  defp normalize(:property), do: @property
  defp normalize( :segment), do: @segment
  defp normalize(     :key), do: @key

end
