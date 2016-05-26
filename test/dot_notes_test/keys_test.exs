defmodule DotNotesTest.KeysTest do
  use ExUnit.Case, async: true

  test "translates basic key" do
    assert(DotNotes.keys("test") == [ "test" ])
  end

  test "translates basic nested key" do
    assert(DotNotes.keys("test.test") == [ "test", "test" ])
  end

  test "translates array key" do
    assert(DotNotes.keys("[0]") == [ 0 ])
  end

  test "translates nested array key" do
    assert(DotNotes.keys("[0][0]") == [ 0, 0 ])
  end

  test "translates basic key under an array key" do
    assert(DotNotes.keys("[0].test") == [ 0, "test" ])
  end

  test "translates array key under a basic key" do
    assert(DotNotes.keys("test[0]") == [ "test", 0 ])
  end

  test "translates blank key" do
    assert(DotNotes.keys("test[\"\"]") == [ "test", "" ])
  end

  test "translates compound key using single quotes" do
    assert(DotNotes.keys("['test']") == [ "test" ])
  end

  test "translates compound key using double quotes" do
    assert(DotNotes.keys("[\"test\"]") == [ "test" ])
  end

  test "translates basic key under a compound key using single quotes" do
    assert(DotNotes.keys("['test'].test") == [ "test", "test" ])
  end

  test "translates basic key under a compound key using double quotes" do
    assert(DotNotes.keys("[\"test\"].test") == [ "test", "test" ])
  end

  test "translates array key under a compound key using single quotes" do
    assert(DotNotes.keys("['test'][0]") == [ "test", 0 ])
  end

  test "translates array key under a compound key using double quotes" do
    assert(DotNotes.keys("[\"test\"][0]") == [ "test", 0 ])
  end

  test "translates integer key using single quotes" do
    assert(DotNotes.keys("['0']") == [ "0" ])
  end

  test "translates integer key using double quotes" do
    assert(DotNotes.keys("[\"0\"]") == [ "0" ])
  end

  test "translates special key using single quotes" do
    assert(DotNotes.keys("[']]][[[']") == [ "]]][[[" ])
  end

  test "translates special key using double quotes" do
    assert(DotNotes.keys("[\"]]][[[\"]") == [ "]]][[[" ])
  end

  test "translates mismatching key using single quotes" do
    assert(DotNotes.keys("['te'st']") == [ "te'st" ])
  end

  test "translates mismatching key using double quotes" do
    assert(DotNotes.keys("[\"te\"st\"]") == [ "te\"st" ])
  end

  test "translates dotted special keys using single quotes" do
    assert(DotNotes.keys("['test.test']") == [ "test.test" ])
  end

  test "translates dotted special keys using double quotes" do
    assert(DotNotes.keys("[\"test.test\"]") == [ "test.test" ])
  end

  test "throw error when provided nil key" do
    assert_raise(DotNotes.ParseException, "Unexpected non-string value provided!", fn ->
      DotNotes.keys(nil)
    end)
  end

  test "throw error when provided empty key" do
    assert_raise(DotNotes.ParseException, "Unable to parse empty string!", fn ->
      DotNotes.keys("")
    end)
  end

  test "throw error when provided invalid key" do
    assert_raise(DotNotes.ParseException, "Unable to parse 'test.1' at character '1', column 6!", fn ->
      DotNotes.keys("test.1")
    end)
  end

  test "throw error when provided invalid bracket notation" do
    assert_raise(DotNotes.ParseException, "Unable to parse 'test.['test']' at character '[', column 6!", fn ->
      DotNotes.keys("test.['test']")
    end)
  end

  test "throw error when provided invalid array notation" do
    assert_raise(DotNotes.ParseException, "Unable to parse 'test.[0]' at character '[', column 6!", fn ->
      DotNotes.keys("test.[0]")
    end)
  end

  test "throw error when provided invalid array index notation" do
    assert_raise(DotNotes.ParseException, "Unable to parse 'test[test]' at character 't', column 6!", fn ->
      DotNotes.keys("test[test]")
    end)
  end

  test "throw error when provided trailing dot" do
    assert_raise(DotNotes.ParseException, "Unable to parse key with trailing dot!", fn ->
      DotNotes.keys("test.")
    end)
  end

  test "throw error when provided trailing bracket" do
    assert_raise(DotNotes.ParseException, "Unable to parse key with trailing bracket!", fn ->
      DotNotes.keys("test[")
    end)
  end

  test "throw error when provided unmatched quotes" do
    assert_raise(DotNotes.ParseException, "Unable to parse '['test]' at character '[', column 1!", fn ->
      DotNotes.keys("['test]")
    end)
  end

  test "throw error when provided sequential dots" do
    assert_raise(DotNotes.ParseException, "Unable to parse 'test..test' at character '.', column 6!", fn ->
      DotNotes.keys("test..test")
    end)
  end

end
