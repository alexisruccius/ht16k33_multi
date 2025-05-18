defmodule Ht16k33MultiTest.DisplayTest do
  use ExUnit.Case

  alias Ht16k33Multi.Display

  describe "all.positions/0" do
    test "display_position to command" do
      assert Display.all_positions() == [0x00, 0x02, 0x06, 0x08]
    end
  end

  describe "colon_on/0" do
    test "colon on command" do
      assert Display.colon_on() == <<0x04, 0x02>>
    end
  end

  describe "colon_off/0" do
    test "colon off command" do
      assert Display.colon_off() == <<0x04, 0x00>>
    end
  end

  describe "clear/0" do
    test "clear display command" do
      assert Display.clear() == <<0x00, 0x00, 0x02, 0x00, 0x06, 0x00, 0x08, 0x00, 0x04, 0x00>>
    end
  end
end
