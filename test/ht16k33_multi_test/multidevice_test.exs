defmodule Ht16k33MultiTest.MultiDevicesTest do
  use ExUnit.Case

  alias Ht16k33Multi.MultiDevices

  describe "split_for_devices/3" do
    test "chunk characters into parts for the devices" do
      characters = "characters for all devices"
      devices = [:red, :green, :blue]

      assert MultiDevices.split_for_devices(characters, devices) == [
               red: "char",
               green: "for",
               blue: "all"
             ]
    end

    test "disable one_word_per_display option" do
      characters = "characters for all devices"
      devices = [:red, :green, :blue]

      assert MultiDevices.split_for_devices(characters, devices, one_word_per_display: false) == [
               red: "char",
               green: "acte",
               blue: "rs f"
             ]
    end

    test "German >Umlaute< (ä, ö, ü) are displayed correct in a word" do
      assert MultiDevices.split_for_devices("hübsch", [:red, :blue], one_word_per_display: false) ==
               [
                 red: "hübs",
                 blue: "ch"
               ]
    end

    test "write spaces to the appended devices that are not used" do
      assert MultiDevices.split_for_devices("hübsch", [:red, :blue, :green],
               one_word_per_display: false
             ) == [
               red: "hübs",
               blue: "ch",
               green: "    "
             ]
    end
  end
end
