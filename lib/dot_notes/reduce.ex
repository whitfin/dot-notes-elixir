defmodule DotNotes.Reduce do
  @moduledoc """
  Reduction module for a haystack, allowing the developer to iterate both keys
  and nests inside a haystack and keep state in an accumulator whilst doing so.

  `DotNotes.recurse/3` is powered by this module under the hood, however the
  existence of `DotNotes.reduce/4` is a deviation from the interfaces defined
  in other dot-notes libraries. This is because accumulation is the only good
  way to keep track of states in Elixir, and so it's only natural to provide it.
  """

  # add macros
  import DotNotes.Util

  # define a haystack type
  @type haystack :: %{ } | [ ]

  @doc """
  Carries out a reduction over a haystack.

  This operates by retrieving a list of keys at each level, iterating through
  them and then nesting into any new levels found. All keys and values are fed
  through to the handler function.

  If desired, the entire path of the current key can also be passed by adding a
  third parameter to the callback. Finally, a fourth parameter of an accumulator
  can be used to maintain state. This is set to `:dn_disabled` if there's no need
  to keep track of state.
  """
  @spec execute(haystack, accumulator :: any, handler :: function, prefix :: binary) :: accumulator :: any
  def execute(haystack, acc, handler, prefix \\ "") do
    needs_path = prefix && needs_path?(handler, acc)
    keys_list  = get_keys(haystack)

    Enum.reduce(keys_list, acc, fn(key, acc) ->
      path = generate_path(key, prefix, needs_path)
      nval = next_value(haystack, key)

      proc_val(key, nval, acc, handler, path)
    end)
  end

  # Calls a handler with the required arguments. If the accumulator has been
  # disabled, then we don't pass that as an argument. In this case we return the
  # existing accumulator to ensure we don't accidentally then start passing one
  # based on the return type. If the accumulator is enabled, we pass it as the
  # last argument, and the return value simply becomes the next accumulator.
  defp call_handler(args, handler, :dn_disabled = acc) do
    apply(handler, args)
    acc
  end
  defp call_handler(args, handler, accumulator) do
    apply(handler, args ++ [ accumulator ])
  end

  # Generates an args list based on the path. If the path is nil, it means that
  # we're not keeping track of the path, and so we don't add it to the arguments.
  defp gen_args(key, next_val, nil) do
    [ key, next_val ]
  end
  defp gen_args(key, next_val, path) do
    [ key, next_val, path ]
  end

  # Generates the new path based on a prefix. If the final arg is false, it means
  # that we don't care about path generation and so we just return nil.
  defp generate_path(_key, _prefix, false) do
    nil
  end
  defp generate_path(key, prefix, true) do
    keystr = DotNotes.escape(key)

    if prefix != "" and String.at(keystr, 0) != "[" do
      "#{prefix}.#{keystr}"
    else
      "#{prefix}#{keystr}"
    end
  end

  # Returns a list of keys for a haystack. When a haystack is a Map, this is just
  # a call to `Map.keys/1`, but for a List we create a range based on the length
  # of the List (acting as though Lists are Maps with integer keys).
  defp get_keys(haystack) when is_list(haystack) do
    0..length(haystack) - 1
  end
  defp get_keys(haystack) when is_map(haystack) do
    Map.keys(haystack)
  end

  # Determines whether we need to generate a path or not. If the accumulator is
  # disabled, we require that the handler has 3 arguments in order to generate a
  # path. If it's enabled, we then require 4 arguments.
  defp needs_path?(handler, :dn_disabled) do
    is_function(handler, 3)
  end
  defp needs_path?(handler, _accumulator) do
    is_function(handler, 4)
  end

  # Retrieves the next value in a haystack. This is split out in order to simplify
  # the branching taken for either a Map or a List. Both return `nil` if the key
  # is not found.
  defp next_value(haystack, key) when is_list(haystack) do
    Enum.at(haystack, key)
  end
  defp next_value(haystack, key) when is_map(haystack) do
    Map.get(haystack, key)
  end

  # Processes a value in the iteration. If the value is a valid haystack, we move
  # into the new level. If it's not, we generate the arguments required and then
  # call the handler with the key/value pairing.
  defp proc_val(_key, next_val, acc, handler, path) when is_haystack(next_val) do
    execute(next_val, acc, handler, path)
  end
  defp proc_val(key, next_val, acc, handler, path) do
    key
    |> gen_args(next_val, path)
    |> call_handler(handler, acc)
  end

end
