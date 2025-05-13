defmodule Ht16k33MultiTest.Display.DimmingTest do
  alias Ht16k33Multi.Display
  use ExUnit.Case

  describe "set/1" do
    test "set right dimming value" do
      assert Display.Dimming.set(1) == <<0xE0>>
      assert Display.Dimming.set(0) == <<0xE0>>
      assert Display.Dimming.set(16) == <<0xEF>>
      assert Display.Dimming.set(169) == <<0xEF>>
    end

    test "set low and high dimming value for values out of scale" do
      assert Display.Dimming.set(0) == <<0xE0>>
      assert Display.Dimming.set(169) == <<0xEF>>
    end
  end
end
