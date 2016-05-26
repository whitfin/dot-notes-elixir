defmodule DotNotesTest.CreateTest do
  use ExUnit.Case, async: true

  test "create using basic key" do
    assert(DotNotes.create("test", 5) == %{ "test" => 5 })
  end

  test "create using basic nested key" do
    assert(DotNotes.create("test.test", 5) == %{ "test" => %{ "test" => 5 } })
  end

  test "create using basic nested key with numbers" do
    assert(DotNotes.create("test.test1", 5) == %{ "test" => %{ "test1" => 5 } })
  end

  test "create using array key" do
    assert(DotNotes.create("[0]", 5) == [ 5 ])
  end

  test "create using nested array key" do
    assert(DotNotes.create("[0][0]", 5) == [ [ 5 ] ])
  end

  test "create using specific array index" do
    assert(DotNotes.create([ 10, 10, 10 ], "[1]", 5) == [ 10, 5, 10 ])
  end

  test "create using basic key under an array key" do
    assert(DotNotes.create("[0].test", 5) == [ %{ "test" => 5 } ])
  end

  test "create using array key under a basic key" do
    assert(DotNotes.create("test[0]", 5) == %{ "test" => [ 5 ] })
  end

  test "create using compound key using single quotes" do
    assert(DotNotes.create("['test']", 5) == %{ "test" => 5 })
  end

  test "create using compound key using double quotes" do
    assert(DotNotes.create("[\"test\"]", 5) == %{ "test" => 5 })
  end

  test "create using basic key under compound key using single quotes" do
    assert(DotNotes.create("['test'].test", 5) == %{ "test" => %{ "test" => 5 } })
  end

  test "create using basic key under compound key using double quotes" do
    assert(DotNotes.create("[\"test\"].test", 5) == %{ "test" => %{ "test" => 5 } })
  end

  test "create using array key under compound key using single quotes" do
    assert(DotNotes.create("['test'][0]", 5) == %{ "test" => [ 5 ] })
  end

  test "create using array key under compound key using double quotes" do
    assert(DotNotes.create("[\"test\"][0]", 5) == %{ "test" => [ 5 ] })
  end

  test "create using integer key using single quotes" do
    assert(DotNotes.create("['10']", 5) == %{ "10" => 5 })
  end

  test "create using integer key using double quotes" do
    assert(DotNotes.create("[\"10\"]", 5) == %{ "10" => 5 })
  end

  test "create using special key using single quotes" do
    assert(DotNotes.create("[']]][[[']", 5) == %{ "]]][[[" => 5 })
  end

  test "create using special key using double quotes" do
    assert(DotNotes.create("[\"]]][[[\"]", 5) == %{ "]]][[[" => 5 })
  end

  test "create missing key in existing object" do
    assert(DotNotes.create(%{ "sing" => 10 }, "dance", 5) == %{
      "sing" => 10,
      "dance" => 5
    })
  end

  test "create existing key in existing object" do
    assert(DotNotes.create(%{ "dance" => 10 }, "dance", 5) == %{
      "dance" => 5
    })
  end

  test "create existing key in existing nested object" do
    assert(DotNotes.create(%{ "dance" => %{ "dance" => 10 } }, "dance.dance", 5) == %{
      "dance" => %{
        "dance" => 5
      }
    })
  end

  test "create using nil value" do
    assert(DotNotes.create("dance", nil) == %{
      "dance" => nil
    })
  end

  test "throw error when provided invalid key" do
    assert_raise(DotNotes.ParseException, "Unable to parse '123' at character '1', column 1!", fn ->
      DotNotes.create("123", 5)
    end)
  end

  test "throw error when provided nil key" do
    assert_raise(DotNotes.ParseException, "Unable to parse invalid string!", fn ->
      DotNotes.create(nil, 5)
    end)
  end

  test "throw error against invalid object target" do
    assert_raise(DotNotes.ParseException, "Expected List target for create call!", fn ->
      DotNotes.create(%{ }, "[0]", 5)
    end)
  end

  test "throw error against invalid list target" do
    assert_raise(DotNotes.ParseException, "Expected Map target for create call!", fn ->
      DotNotes.create([], "test", 5)
    end)
  end

end
