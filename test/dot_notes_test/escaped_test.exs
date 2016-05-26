defmodule DotNotesTest.EscapedTest do
  use ExUnit.Case, async: true

  test "check if a basic key is escaped" do
    assert(DotNotes.escaped?("test"))
  end

  test "check if an array key is escaped" do
    assert(DotNotes.escaped?("[0]"))
  end

  test "check if a single quoted key is escaped" do
    assert(DotNotes.escaped?("['test']"))
  end

  test "check if a double quoted key is escaped" do
    assert(DotNotes.escaped?("[\"test\"]"))
  end

  test "check if a blank key is escaped" do
    assert(DotNotes.escaped?("[\"\"]"))
  end

  test "check if an empty key is escaped" do
    refute(DotNotes.escaped?(""))
  end

  test "check if a numeric key is escaped" do
    refute(DotNotes.escaped?("5"))
  end

  test "check if a special key is escaped" do
    refute(DotNotes.escaped?("my-test"))
  end

  test "check if an unwrapped single quoted key is escaped" do
    refute(DotNotes.escaped?("'test'"))
  end

  test "check if an unwrapped double quoted key is escaped" do
    refute(DotNotes.escaped?("\"test\""))
  end

  test "check if a missing key is escaped" do
    refute(DotNotes.escaped?(nil))
  end

end
