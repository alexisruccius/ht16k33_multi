defmodule Ht16k33MultiTest.Display.DimmingTest do
  alias Ht16k33Multi.Display
  use ExUnit.Case

  describe "set/1" do
    test "set right dimming value" do
      assert Display.Dimming.set(1) == <<0xE0>>
      assert Display.Dimming.set(2) == <<0xE1>>
      assert Display.Dimming.set(3) == <<0xE2>>
      assert Display.Dimming.set(4) == <<0xE3>>
      assert Display.Dimming.set(5) == <<0xE4>>
      assert Display.Dimming.set(6) == <<0xE5>>
      assert Display.Dimming.set(7) == <<0xE6>>
      assert Display.Dimming.set(8) == <<0xE7>>
      assert Display.Dimming.set(9) == <<0xE8>>
      assert Display.Dimming.set(10) == <<0xE9>>
      assert Display.Dimming.set(11) == <<0xEA>>
      assert Display.Dimming.set(12) == <<0xEB>>
      assert Display.Dimming.set(13) == <<0xEC>>
      assert Display.Dimming.set(14) == <<0xED>>
      assert Display.Dimming.set(15) == <<0xEE>>
      assert Display.Dimming.set(16) == <<0xEF>>
    end

    test "set low and high dimming value for values out of scale" do
      assert Display.Dimming.set(0) == <<0xE0>>
      assert Display.Dimming.set(169) == <<0xEF>>
      assert Display.Dimming.set(-69) == <<0xEF>>
    end
  end
end
