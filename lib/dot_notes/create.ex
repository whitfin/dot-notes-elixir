defmodule DotNotes.Create do
  @moduledoc """
  Module containing creation based actions for DotNotes. Due to the recursion it
  made sense to split this into a separate module in order to avoid bloating the
  main module with private functions.
  """

  # add an excetpion alias
  alias DotNotes.ParseException, as: PEx

  # define a haystack type
  @type haystack :: %{ } | [ ]

  @doc """
  Creates a key/value pair inside a haystack using a path.

  Most of the heavy lifting here is done by the recursive (and private) `create_nest/3`
  function which iterates deeper into the haystack. We use `DotNotes.keys/1` to
  generate our key list rather than reimplementing a parser here.
  """
  @spec execute(haystack | nil, path :: binary, value :: any) :: haystack
  def execute(haystack, path, value) do
    [ first | _ ] = key_list = DotNotes.keys(path)

    haystack
    |> set_target(first)
    |> create_nest(key_list, value)
  end

  # Creates a nested value in a haystack based on a list of keys. If we only have
  # a single key left, then we write the value against the key. Otherwise we create
  # nest based on the type of key to iterate deeper. Once the key has been written
  # in the lowest nest, we iterate straight back up and write the new haystacks
  # as we go.
  defp create_nest(haystack, [ key ], value) when is_binary(key) do
    Map.put(haystack, key, value)
  end
  defp create_nest(haystack, [ key ], value) when is_number(key) do
    list_set(haystack, key, value)
  end
  defp create_nest(haystack, [ first, second | keys ], value) when is_binary(first) do
    inner_nest =
      haystack
      |> Map.get(first)
      |> do_nest(second, keys, value)

    Map.put(haystack, first, inner_nest)
  end
  defp create_nest(haystack, [ first, second | keys ], value) when is_number(first) do
    inner_nest =
      haystack
      |> Enum.at(first)
      |> do_nest(second, keys, value)

    list_set(haystack, first, inner_nest)
  end

  # Determines which type of nest needs to be created based on the key type provided.
  # If there is no level at this point, we create a new level using the key type,
  # otherwise we simply iterate into the new level.
  defp do_nest(nil, next_key, keys, value) when is_binary(next_key) do
    create_nest(%{ }, [ next_key | keys ], value)
  end
  defp do_nest(nil, next_key, keys, value) when is_number(next_key) do
    create_nest([ ], [ next_key | keys ], value)
  end
  defp do_nest(level, next_key, keys, value) do
    create_nest(level, [ next_key | keys ], value)
  end

  # Sets a position in the list based on the list size. If the list is the same
  # length as the index we want to pass, we append the value. Otherwise we do
  # a list replace at the provided index for safety. This means that if the list
  # is not long enough to set the index desired, we fall back to the Elixir std
  # behaviour of changing nothing.
  defp list_set(list, index, value) when length(list) == index do
    List.insert_at(list, -1, value)
  end
  defp list_set(list, index, value) do
    List.replace_at(list, index, value)
  end

  # Determines the target we should create the path inside. If the provided target
  # is `nil`, we create it based on the type of the first key. Otherwise we check
  # that the types match correctly and throw errors if they do not.
  defp set_target(nil, key) when is_binary(key), do: %{}
  defp set_target(nil, key) when is_number(key), do:  []
  defp set_target(val, key) when is_map(val) and is_number(key) do
    PEx.raise("Expected List target for create call!")
  end
  defp set_target(val, key) when is_list(val) and is_binary(key) do
    PEx.raise("Expected Map target for create call!")
  end
  defp set_target(val, _key), do: val
end
