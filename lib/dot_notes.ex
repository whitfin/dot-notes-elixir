defmodule DotNotes do
  @moduledoc """
  This module provides several functions to deal with Maps and Lists and various
  levels of nesting. It is based on the project found at https://github.com/zackehh/dot-notes.

  Specifically in Elixir, writing homebrew functions for nesting is quite painful
  due to both immutability and recursion. DotNotes will remove this pain by adding
  a very simple interface to achieve just that.

  Please note that this module deals with pure JSON structures, and as such Tuples
  are unsupported (although if there's a demand I may add them in future).
  """

  # add macros
  import DotNotes.Util

  # alias the exception module
  alias DotNotes.ParseException, as: PEx

  # alias actions
  alias DotNotes.Create
  alias DotNotes.Get
  alias DotNotes.Keys
  alias DotNotes.Pattern
  alias DotNotes.Reduce

  # define a haystack type
  @type haystack :: %{ } | [ ]

  @doc """
  Creates a key/value pair inside a haystack using a path.

  If the path is not a valid binary, an error will be raised. The returned
  value is the provided haystack with the key/value created. Any required nests
  will be created automatically.

  If you omit the haystack, or set it to `nil`, it will be created based upon
  the type of the first key in your path.

  ## Examples

      iex> DotNotes.create(%{ }, "map.list[0]", :ok)
      %{ "map" => %{ "list" => [ :ok ] } }

      iex> DotNotes.create([ ], "[0].map", :ok)
      [ %{ "map" => :ok } ]

      iex> DotNotes.create("map.list[0]", :ok)
      %{ "map" => %{ "list" => [ :ok ] } }

      iex> DotNotes.create("[0].map", :ok)
      [ %{ "map" => :ok } ]

      iex> DotNotes.create(%{ "test" => true }, "map.list[0]", :ok)
      %{ "map" => %{ "list" => [ :ok ] }, "test" => true }

      iex> DotNotes.create([ :ok ], "[1].map", :ok)
      [ :ok,  %{ "map" => :ok } ]

  """
  @spec create(haystack | nil, path :: binary, value :: any) :: haystack
  def create(haystack \\ nil, path, value)
  def create(_haystack, path, _value) when not is_binary(path) do
    PEx.raise( "Unable to parse invalid string!")
  end
  def create(haystack, path, value) do
    Create.execute(haystack, path, value)
  end

  @doc """
  Escapes a binary to a valid notation form.

  If a number if provided it is wrapped inside an array index, and if a binary
  is provided we determine if it's an accessor or not; if so we return as it,
  otherwise we escaped all quotes and wrap in special syntax.

  ## Examples

      iex> DotNotes.escape(1)
      "[1]"

      iex> DotNotes.escape("1")
      to_string('["1"]')

      iex> DotNotes.escape("][")
      to_string('["]["]')

      iex> DotNotes.escape(%{ })
      ** (DotNotes.ParseException) Unexpected key value provided!

  """
  @spec escape(key :: binary) :: escaped :: binary
  def escape(key) when is_binary(key) do
    if Pattern.matches?(key, :accessor) do
      key
    else
      "[\"#{String.replace(key, "\"", "\\\"")}\"]"
    end
  end
  def escape(key) when is_number(key) do
    "[#{key}]"
  end
  def escape(_key) do
    PEx.raise("Unexpected key value provided!")
  end

  @doc """
  Checks if a key is already valid notation.

  If the value is not a binary, `false` will be returned. Otherwise you will
  receive either `true` or `false` based on whether the key is correctly escaped.

  ## Examples

      iex> DotNotes.escaped?("[1]")
      true

      iex> DotNotes.escaped?(to_string('["1"]'))
      true

      iex> DotNotes.escaped?(to_string('["]["]'))
      true

      iex> DotNotes.escaped?(".")
      false

      iex> DotNotes.escaped?(%{ })
      false

  """
  @spec escaped?(key :: binary) :: true | false
  def escaped?(key) do
    is_binary(key) && Pattern.matches?(key, :key)
  end

  @doc """
  Retrieves a potentially nested key from a haystack.

  If the path is not a valid binary, an error will be raised. The returned value
  will be the value stored at the end of the path. If the path cannot be traversed,
  a `nil` value will be returned.

  ## Examples

      iex> DotNotes.get(%{ "test" => [ 1 ] }, "test[0]")
      1

      iex> DotNotes.get([ %{ "test" => 1 } ], "[0].test")
      1

      iex> DotNotes.get([ %{ "test" => 1 } ], "[0][0]")
      nil

      iex> DotNotes.get("invalid_haystack", "[0][0]")
      nil

      iex> DotNotes.get(%{ }, "")
      ** (DotNotes.ParseException) Unable to parse empty string!

  """
  @spec get(haystack, path :: binary) :: value :: any
  def get(_haystack, path) when not is_binary(path) do
    PEx.raise("Unable to parse empty string!")
  end
  def get(haystack, _path) when not is_haystack(haystack) do
    nil
  end
  def get(haystack, needle) do
    Get.execute(haystack, needle)
  end

  @doc """
  Parses a binary notation into a list of keys.

  If the notation is invalid, errors will be raised. Array-based keys will be
  parsed into numbers, and binary keys will remain binary. This is how you can
  determine what your structures look like.

  ## Examples

      iex> DotNotes.keys("this.is.a.test")
      [ "this", "is", "a", "test" ]

      iex> DotNotes.keys("list[0].test")
      [ "list", 0, "test" ]

      iex> DotNotes.keys(to_string('list["]["].test'))
      [ "list", "][", "test" ]

      iex> DotNotes.keys(%{ })
      ** (DotNotes.ParseException) Unexpected non-string value provided!

      iex> DotNotes.keys("")
      ** (DotNotes.ParseException) Unable to parse empty string!

  """
  @spec keys(notation :: binary) :: keys :: [ binary | number ]
  def keys(notation) when not is_binary(notation) do
    PEx.raise("Unexpected non-string value provided!")
  end
  def keys(notation) when byte_size(notation) == 0 do
    PEx.raise("Unable to parse empty string!")
  end
  def keys(notation) do
    Keys.execute(0, notation, [])
  end

  @doc """
  Iterates a haystack, nesting appropriately and feeding all values to a handler.

  The handler should be either arity `2` or `3`, and accept arguments in the form
  of `fn(key, value, path)`. If you have no use for the `path` argument, drop it
  from your function definition and DotNotes won't generate these paths. This is
  a performance boost for heavily nested objects.

  A prefix can be provided if you wish to append paths with a custom prefix. This
  defaults to a blank binary, but it can be useful if you're parsing nests.

  If a valid haystack is not provided, errors will be raised.

  ## Examples

      iex> DotNotes.recurse([ 1, 2, 3 ], fn(key, value) ->
      ...>   Enum.join([ key, value ], " : ")
      ...> end)
      :ok

      iex> DotNotes.recurse([ 1, 2, 3 ], fn(key, value, path) ->
      ...>   Enum.join([ key, value, path ], " : ")
      ...> end)
      :ok

      iex> DotNotes.recurse("", fn(_key, value) -> value end)
      ** (ArgumentError) Invalid haystack provided to DotNotes.recurse/3

  """
  @spec recurse(haystack, handler :: function, prefix :: binary) :: :ok
  def recurse(haystack, handler, prefix \\ "")
  def recurse(haystack, _handler, _prefix) when not is_haystack(haystack) do
    raise ArgumentError, message: "Invalid haystack provided to DotNotes.recurse/3"
  end
  def recurse(haystack, handler, prefix) do
    reduce(haystack, :dn_disabled, handler, prefix)
    :ok
  end

  @doc """
  Same as `recurse/3`, but allows the passing of an accumulator.

  An accumulator will store the returned value of your handler and pass through
  to the next. This is a diversion from the JavaScript API due to the fact that
  it's the only way to set any variables inside Elixir in this type of iteration.

  If a valid haystack is not provided, errors will be raised.

  ## Examples

      iex> DotNotes.reduce([ 1, 2, 3 ], 0, fn(_key, value, acc) ->
      ...>   acc + value
      ...> end)
      6

      iex> DotNotes.reduce([ 1, 2, 3 ], 0, fn(_key, value, _path, acc) ->
      ...>   acc + value
      ...> end)
      6

      iex> DotNotes.reduce("", 0, fn(_key, value) -> value end)
      ** (ArgumentError) Invalid haystack provided to DotNotes.reduce/4

  """
  @spec reduce(haystack, accumulator :: any, handler :: function, prefix :: binary) :: accumulator :: any
  def reduce(haystack, acc, handler, prefix \\ "")
  def reduce(haystack, _acc, _handler, _prefix) when not is_haystack(haystack) do
    raise ArgumentError, message: "Invalid haystack provided to DotNotes.reduce/4"
  end
  def reduce(haystack, acc, handler, prefix) do
    Reduce.execute(haystack, acc, handler, prefix)
  end

end
