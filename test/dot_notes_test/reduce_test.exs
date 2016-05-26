defmodule DotNotesTest.ReduceTest do
  use ExUnit.Case, async: true

  test "iterates basic keys" do
    map = %{
      "one" => 1,
      "two" => 2,
      "three" => 3
    }

    keys = Map.keys(map)

    count = DotNotes.reduce(map, 0, fn(key, value, path, acc) ->
      idx = acc + 1

      assert(Enum.at(keys, acc) == key)
      assert(Map.get(map, Enum.at(keys, acc)) == value)
      assert(key == path)

      idx
    end)

    assert(count == 3)
  end

  test "iterates array keys" do
    arr = [ 1 ]

    count = DotNotes.reduce(arr, 0, fn(key, value, path, acc) ->
      assert(key == 0)
      assert(value == 1)
      assert(path == "[0]")
      acc + 1
    end)

    assert(count == 1)
  end

  test "iterates special keys" do
    map = %{
      "][" => 1,
      "\"" => 2,
      "'" => 3
    }

    keys = Map.keys(map)

    count = DotNotes.reduce(map, 0, fn(key, value, path, acc) ->
      idx = acc + 1

      assert(Enum.at(keys, acc) == key)
      assert(Map.get(map, Enum.at(keys, acc)) == value)
      assert(DotNotes.escape(key) == path)

      idx
    end)

    assert(count == 3)
  end

  test "iterates maps recursively" do
    map = %{
      "test" => %{
        "nested" => %{
          "objects" => 1
        }
      }
    }

    count = DotNotes.reduce(map, 0, fn(key, value, path, acc) ->
      assert(key == "objects")
      assert(value == 1)
      assert(path == "test.nested.objects")

      acc + 1
    end)

    assert(count == 1)
  end

  test "iterates arrays recursively" do
    arr =  [ [ 1 ] ]

    count = DotNotes.reduce(arr, 0, fn(key, value, path, acc) ->
      assert(key == 0)
      assert(value == 1)
      assert(path == "[0][0]")

      acc + 1
    end)

    assert(count == 1)
  end

  test "iterates arrays and objects recursively" do
    map = %{
      "array" => [
        %{
          "test" => %{
            "nested" =>  [
              %{
                "recursion" => %{
                  "0" => 1
                }
              }
            ]
          }
        }
      ]
    }

    count = DotNotes.reduce(map, 0, fn(key, value, path, acc) ->
      assert(key == "0")
      assert(value == 1)
      assert(path == "array[0].test.nested[0].recursion[\"0\"]")

      acc + 1
    end)

    assert(count == 1)
  end

  test "iterates nil values" do
    map = %{
      "test" => nil
    }

    count = DotNotes.reduce(map, 0, fn(key, value, path, acc) ->
      assert(key == "test")
      assert(value == nil)
      assert(path == "test")

      acc + 1
    end)

    assert(count == 1)
  end

  test "iterates using a custom prefix" do
    map = %{
      "test" => nil
    }

    count = DotNotes.reduce(map, 0, fn(key, value, path, acc) ->
      assert(key == "test")
      assert(value == nil)
      assert(path == "prefix.test")

      acc + 1
    end, "prefix")

    assert(count == 1)
  end

  test "iterates without path generation" do
    map = %{
      "test" => nil
    }

    count = DotNotes.reduce(map, 0, fn(key, value, acc) ->
      assert(key == "test")
      assert(value == nil)

      acc + 1
    end)

    assert(count == 1)
  end

  test "throw error when provided invalid haystack" do
    assert_raise(ArgumentError, "Invalid haystack provided to DotNotes.reduce/4", fn ->
      DotNotes.reduce("test", 0, fn(_, _, _, _) -> 1 end)
    end)
  end

end
