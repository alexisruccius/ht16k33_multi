defmodule Ht16k33MultiTest.Display.BlinkingTest do
  use ExUnit.Case

  alias Ht16k33Multi.Display.Blinking

  describe "on/0" do
    test "default speed is 0.5 Hz" do
      assert Blinking.on() == 0x87
    end
  end

  describe "on/1" do
    test "speed is 0.5 Hz" do
      assert Blinking.on(0) == 0x87
    end

    test "speed is 1 Hz" do
      assert Blinking.on(1) == 0x85
    end

    test "speed is 2 Hz" do
      assert Blinking.on(2) == 0x83
    end

    test "speed is 2 Hz for out of scale values" do
      assert Blinking.on(69) == 0x83
    end
  end

  describe "off/0" do
    test "blinking off" do
      assert Blinking.off() == 0x81
    end
  end
end
