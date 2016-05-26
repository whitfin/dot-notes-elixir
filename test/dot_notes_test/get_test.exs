defmodule DotNotesTest.GetTest do
  use ExUnit.Case, async: true

  test "get using basic key" do
    assert(DotNotes.get(%{ "test" => 5 }, "test") == 5)
  end

  test "get using basic nested key" do
    assert(DotNotes.get(%{ "test" => %{ "test" => 5 } }, "test.test") == 5)
  end

  test "get using array key" do
    assert(DotNotes.get([ 5 ], "[0]") == 5)
  end

  test "get using array nested key" do
    assert(DotNotes.get([ [ 5 ] ], "[0][0]") == 5)
  end

  test "get using basic key under array key" do
    assert(DotNotes.get([ %{ "test" => 5 } ], "[0].test") == 5)
  end

  test "get using array key under basic key" do
    assert(DotNotes.get(%{ "test" => [ 5 ] }, "test[0]") == 5)
  end

  test "get using compound key using single quotes" do
    assert(DotNotes.get(%{ "test" => 5 }, "['test']") == 5)
  end

  test "get using compound key using double quotes" do
    assert(DotNotes.get(%{ "test" => 5 }, "[\"test\"]") == 5)
  end

  test "get using basic key under compound key using single quotes" do
    assert(DotNotes.get(%{ "test" => %{ "test" => 5 } }, "['test'].test") == 5)
  end

  test "get using basic key under compound key using double quotes" do
    assert(DotNotes.get(%{ "test" => %{ "test" => 5 } }, "[\"test\"].test") == 5)
  end

  test "get using array key under compound key using single quotes" do
    assert(DotNotes.get(%{ "test" => [ 5 ] }, "['test'][0]") == 5)
  end

  test "get using array key under compound key using double quotes" do
    assert(DotNotes.get(%{ "test" => [ 5 ] }, "[\"test\"][0]") == 5)
  end

  test "get using integer key using single quotes" do
    assert(DotNotes.get(%{ "0" => 5 }, "['0']") == 5)
  end

  test "get using integer key using double quotes" do
    assert(DotNotes.get(%{ "0" => 5 }, "[\"0\"]") == 5)
  end

  test "get using special key using single quotes" do
    assert(DotNotes.get(%{ "]]][[[" => 5 }, "[']]][[[']") == 5)
  end

  test "get using special key using double quotes" do
    assert(DotNotes.get(%{ "]]][[[" => 5 }, "[\"]]][[[\"]") == 5)
  end

  test "get using missing path" do
    assert(DotNotes.get(%{ }, "test") == nil)
  end

  test "get using missing target" do
    assert(DotNotes.get(nil, "test") == nil)
  end

  test "get using missing nested target" do
    assert(DotNotes.get(%{ }, "test.test") == nil)
  end

  test "get using missing nested path" do
    assert(DotNotes.get(%{ "test" => %{ "test" => nil } }, "test.test.test") == nil)
  end

  test "throw error when provided invalid key" do
    assert_raise(DotNotes.ParseException, "Unable to parse '123' at character '1', column 1!", fn ->
      DotNotes.get(%{ }, "123")
    end)
  end

  test "throw error when provided nil key" do
    assert_raise(DotNotes.ParseException, "Unable to parse empty string!", fn ->
      DotNotes.get(%{ }, nil)
    end)
  end

end
