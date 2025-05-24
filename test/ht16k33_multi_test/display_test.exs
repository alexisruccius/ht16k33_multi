defmodule Ht16k33MultiTest.DisplayTest do
  use ExUnit.Case

  alias Ht16k33Multi.Display

  describe "initialize/0" do
    test "turns on oscillation and clears all segments command" do
      oscillation = 0x21
      display_on = 0x81
      clear_command = <<0, 0, 2, 0, 6, 0, 8, 0, 4, 0>>

      assert Display.initialize() == [oscillation, display_on, clear_command]
    end
  end

  describe "oscillation_on/0" do
    test "oscillation_on command" do
      assert Display.oscillation_on() == 0x21
    end
  end

  describe "display_on/0" do
    test "display_on command" do
      assert Display.display_on() == 0x81
    end
  end

  describe "display_off/0" do
    test "display_off command" do
      assert Display.display_off() == 0x80
    end
  end

  describe "all_positions/0" do
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
