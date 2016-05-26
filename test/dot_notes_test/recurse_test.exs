defmodule DotNotesTest.RecurseTest do
  use ExUnit.Case, async: true

  test "recursing without an accumulator" do
    map = %{ "one" => 1 }

    res = DotNotes.recurse(map, fn(key, value, path) ->
      assert(key == "one")
      assert(value == 1)
      assert(key == path)
    end)

    assert(res == :ok)
  end

  test "recursing without a path" do
    map = %{ "one" => 1 }

    res = DotNotes.recurse(map, fn(key, value) ->
      assert(key == "one")
      assert(value == 1)
    end)

    assert(res == :ok)
  end

  test "throw error when provided invalid haystack" do
    assert_raise(ArgumentError, "Invalid haystack provided to DotNotes.recurse/3", fn ->
      DotNotes.recurse("test", fn(_, _, _) -> 1 end)
    end)
  end

end
