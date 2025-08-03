defmodule Ht16k33MultiTest.FontTest do
  use ExUnit.Case, async: true

  alias Ht16k33Multi.Font

  describe "segments/1" do
    test "char to 7-segment hex command for one char" do
      assert Font.segments("a") == [0x77]
      assert Font.segments("A") == [0x77]
      assert Font.segments(1) == [0x06]
      assert Font.segments(6) == [0x7D]
      assert Font.segments(9) == [0x6F]
      assert Font.segments(69) == [0x7D, 0x6F]
      assert Font.segments(1981) == [0x06, 0x6F, 0x7F, 0x06]
    end

    test "char to 7-segment hex command for multiple chars (words?)" do
      assert Font.segments("10") == [0x06, 0x3F]
      assert Font.segments("1981") == [0x06, 0x6F, 0x7F, 0x06]
    end

    test "chars without segments configuration" do
      assert Font.segments("|") == [0x00]
      assert Font.segments("|%") == [0x00, 0x00]
    end

    test "display German >Umlaute< ä, ü, ö, and ß as a, u, o, and s" do
      assert Font.segments("ä") == [0x77]
      assert Font.segments("ö") == [0x3F]
      assert Font.segments("ü") == [0x3E]
      assert Font.segments("ß") == [0x6D]
    end

    test "Unknown strings bigger than 1 byte, but only one char, like è" do
      assert Font.segments("è") == [0x00]
    end

    test "apostrophe like chars >'<" do
      assert Font.segments("'") == [0x20]
      assert Font.segments("`") == [0x20]
      assert Font.segments("´") == [0x20]
    end
  end
end
