defmodule DotNotesTest.EscapeTest do
  use ExUnit.Case, async: true

  test "escape using a basic key" do
    assert(DotNotes.escape("test") == "test")
  end

  test "escape using a numeric key" do
    assert(DotNotes.escape("0") == "[\"0\"]")
  end

  test "escape using a numeric key index" do
    assert(DotNotes.escape(0) == "[0]")
  end

  test "escape using a special key" do
    assert(DotNotes.escape("my-test") == "[\"my-test\"]")
  end

  test "escape using a single quoted key" do
    assert(DotNotes.escape("'test'") == "[\"'test'\"]")
  end

  test "escape using a double quoted key" do
    assert(DotNotes.escape("\"test\"") == "[\"\\\"test\\\"\"]")
  end

  test "escape using an empty string" do
    assert(DotNotes.escape("") == "[\"\"]")
  end

  test "throw error against nil value" do
    assert_raise(DotNotes.ParseException, "Unexpected key value provided!", fn ->
      DotNotes.escape(nil)
    end)
  end

end
