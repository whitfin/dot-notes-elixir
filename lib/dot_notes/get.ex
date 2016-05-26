defmodule DotNotes.Get do
  @moduledoc """
  Module containing retrieval based actions for DotNotes. Due to the recursion it
  made sense to split this into a separate module in order to avoid bloating the
  main module with private functions.
  """

  # define a haystack type
  @type haystack :: %{ } | [ ]

  @doc """
  Retrieves a value from a haystack using a provided path.

  We use a basic `Enum.reduce_while/2` iteration so we can exit early in the case
  of a missing branch.
  """
  @spec execute(haystack, path :: binary) :: value :: any
  def execute(haystack, path) do
    path
    |> DotNotes.keys
    |> Enum.reduce_while(haystack, &do_nest/2)
  end

  # Moves into a nest based on the current level and the type of the next key.
  # If the types don't match up, then we simply exit the recursion and return
  # a `nil` value.
  defp do_nest(key, level) when is_binary(key) and is_map(level) do
    { :cont, Map.get(level, key) }
  end
  defp do_nest(key, level) when is_number(key) and is_list(level) do
    { :cont, Enum.at(level, key) }
  end
  defp do_nest(_key, _level) do
    { :halt, nil }
  end

end
