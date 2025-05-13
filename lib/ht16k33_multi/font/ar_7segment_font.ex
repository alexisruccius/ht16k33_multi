defmodule Ht16k33Multi.Font.Ar7segmentFont do
  @moduledoc """
  Provides the `AR-7-segment-font` used for rendering characters on a 7-segment display.

  For details on how this font is applied, see the `Ht16k33Multi.Font` module documentation.
  """
  @moduledoc since: "0.1.0"

  @doc """
  Returns a map representing the `AR-7-segment` font.

  The map contains the binary encoding for each character, which corresponds to the byte values
  used to display on a 7-segment display.
  """
  @doc since: "0.1.0"
  @spec map() :: %{optional(nonempty_binary()) => byte()}
  def map() do
    %{
      " " => 0x00,
      "." => 0x80,
      ":" => 0x80,
      "," => 0x80,
      "'" => 0x20,
      "`" => 0x20,
      "´" => 0x20,
      "!" => 0x82,
      "?" => 0xD3,
      "(" => 0x21,
      ")" => 0x0C,
      "\"" => 0x02,
      "-" => 0x40,
      "_" => 0x08,
      "0" => 0x3F,
      "1" => 0x06,
      "2" => 0x5B,
      "3" => 0x4F,
      "4" => 0x66,
      "5" => 0x6D,
      "6" => 0x7D,
      "7" => 0x07,
      "8" => 0x7F,
      "9" => 0x6F,
      "A" => 0x77,
      "Ä" => 0x77,
      "B" => 0x7F,
      "C" => 0x39,
      "D" => 0x0F,
      "E" => 0x79,
      "F" => 0x71,
      "G" => 0x3D,
      "H" => 0x76,
      "I" => 0x06,
      "J" => 0x1E,
      "K" => 0x7A,
      "L" => 0x38,
      "M" => 0x37,
      "N" => 0x37,
      "O" => 0x3F,
      "Ö" => 0x3F,
      "P" => 0x73,
      "Q" => 0x67,
      "R" => 0x33,
      "S" => 0x6D,
      "SS" => 0x6D,
      "T" => 0x07,
      "U" => 0x3E,
      "Ü" => 0x3E,
      "V" => 0x72,
      "W" => 0x7E,
      "X" => 0x76,
      "Y" => 0x6E,
      "Z" => 0x5B
    }
  end
end
