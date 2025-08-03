defmodule Ht16k33Multi.Font do
  @moduledoc """
  Font for the `Ht16k33` 7-segment display.
  This module converts characters into segment data for the display.


  ## Command Structure for the 7-Segment Display

  One position on the 7-segment display:

              1
             ___
        (2) |   | 2
        (4)  ---
        (1) |   | 4
             ---  * (8)
              8

  Where:
  - `(x)` represents the first hex value
  - `x` represents the last hex value

  ### Examples:

  - For the character "0", the segments (2), (1) (= 3) and segments 1, 2, 4, 8 (= 15 = hex F) are lit. This corresponds to the hex value `0x3F`.
  - For the character "4", the segments (2), (4) (= 6) and segments 2, 4 (= 6) are lit. This corresponds to the hex value `0x66`.

  ### Segment Hex Mappings:

  |      | SEGMENTS_ON |
  | HEX  |  8  4  2  1 |
  |------|-------------|
  | 0    |  0  0  0  0 |
  | 1    |  0  0  0  1 |
  | 2    |  0  0  1  0 |
  | 3    |  0  0  1  1 |
  | 4    |  0  1  0  0 |
  | 5    |  0  1  0  1 |
  | 6    |  0  1  1  0 |
  | 7    |  0  1  1  1 |
  | 8    |  1  0  0  0 |
  | 9    |  1  0  0  1 |
  | A    |  1  0  1  0 |
  | B    |  1  0  1  1 |
  | C    |  1  1  0  0 |
  | D    |  1  1  0  1 |
  | E    |  1  1  1  0 |
  | F    |  1  1  1  1 |
  """
  @moduledoc since: "0.1.0"

  alias Ht16k33Multi.Font.Ar7segmentFont

  @doc """
  Converts characters or integers to their corresponding hexadecimal values
  for displaying the correct segments on a 7-segment display.
  For example, the letter "A" is displayed with the command `0x77`.

  This function returns the hexadecimal segment commands for a string of characters
  or an integer to be displayed on the 7-segment display.
  """
  @doc since: "0.1.0"
  @spec segments(String.t() | integer()) :: list(integer())
  def segments(characters)

  def segments(characters) when is_integer(characters),
    do: characters |> Integer.to_string() |> segments()

  def segments(characters),
    do: characters |> String.codepoints() |> Enum.map(&to_segment/1)

  defp to_segment(character),
    do: Ar7segmentFont.map() |> Map.get(character |> String.upcase(), default_write_nothing())

  defp default_write_nothing, do: 0x00
end
