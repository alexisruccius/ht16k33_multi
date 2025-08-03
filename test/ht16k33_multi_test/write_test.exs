defmodule Ht16k33MultiTest.WriteTest do
  use ExUnit.Case, async: true

  alias Ht16k33Multi.Write

  describe "to_display/1" do
    test "write chars to display command" do
      assert Write.to_display("Hola") == [
               <<0x00, 0x76>>,
               <<0x02, 0x3F>>,
               <<0x06, 0x38>>,
               <<0x08, 0x77>>
             ]
    end

    test "if there are less than 4 chars, white spaces are used to display empty space" do
      # 3 chars
      assert Write.to_display("Hol") == [
               <<0x00, 0x76>>,
               <<0x02, 0x3F>>,
               <<0x06, 0x38>>,
               <<0x08, 0x00>>
             ]

      # 2 chars
      assert Write.to_display("Ho") == [
               <<0x00, 0x76>>,
               <<0x02, 0x3F>>,
               <<0x06, 0x00>>,
               <<0x08, 0x00>>
             ]

      # 1 chars
      assert Write.to_display("H") == [
               <<0x00, 0x76>>,
               <<0x02, 0x00>>,
               <<0x06, 0x00>>,
               <<0x08, 0x00>>
             ]

      # 0 chars
      assert Write.to_display("") == [
               <<0x00, 0x00>>,
               <<0x02, 0x00>>,
               <<0x06, 0x00>>,
               <<0x08, 0x00>>
             ]
    end

    test "if there are more than 4 chars, display only 4" do
      # 5 chars
      assert Write.to_display("Holal") == [
               <<0x00, 0x76>>,
               <<0x02, 0x3F>>,
               <<0x06, 0x38>>,
               <<0x08, 0x77>>
             ]

      # 8 chars
      assert Write.to_display("Holalala") == [
               <<0x00, 0x76>>,
               <<0x02, 0x3F>>,
               <<0x06, 0x38>>,
               <<0x08, 0x77>>
             ]
    end

    test "German >Umlaute< (ä, ö, ü) are displayed correct in a word" do
      assert Write.to_display("hübsch") == [
               <<0x00, 0x76>>,
               <<0x02, 0x3E>>,
               <<0x06, 0x7F>>,
               <<0x08, 0x6D>>
             ]
    end
  end
end
