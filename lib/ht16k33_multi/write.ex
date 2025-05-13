defmodule Ht16k33Multi.Write do
  @moduledoc """

  Prepares display data by combining character segments with their corresponding positions.

  Each 7-segment display has 4 character positions, each with its own memory address,
  see `Ht16k33Multi.Display`.
  This module maps each character to the appropriate segment representation and assigns it
  to the correct position address. It outputs the data format expected by the `Ht16k33` device
  for writing via the I2C bus.

    > 💡 To simplify usage, please use the `Ht16k33Multi` GenServer module,
    such as calling `Ht16k33Multi.write/1` for ease of interaction.
  """
  @moduledoc since: "0.1.0"

  alias Ht16k33Multi.{Display, Font}

  @doc """
  Converts a string or integer into a list of 7-segment display commands.

  The characters are transformed using the `Font` module into segment codes,
  and each of the first 4 characters is paired with a display position.
  If fewer than 4 characters are provided, the remaining positions are padded with spaces.
  If more than 4 characters are provided, the excess characters are discarded.

  The output is a list of bitstrings formatted for writing to the display using the `I2cBus` module.

    > 💡 To simplify usage, please use the `Ht16k33Multi` GenServer module,
    such as calling `Ht16k33Multi.write/1` for ease of interaction.

  ## Example

      iex> i2c_bus = "i2c-1"
      iex> {:ok, i2c_ref} = Circuits.I2C.open(i2c_bus)
      iex> name = :red_leds
      iex> address = 0x70
      iex> Ht16k33Multi.Write.to_display("Hi 1")
      ...> |> Ht16k33Multi.I2cBus.write(%Ht16k33Multi{name: name, i2c_ref: i2c_ref, address: address})

  """
  @doc since: "0.1.0"
  @spec to_display(binary() | integer()) :: list()
  def to_display(character) when byte_size(character) <= 1,
    do: to_display(character <> "   ")

  def to_display(characters) do
    [Display.all_positions(), Font.segments(characters) |> check_4_elements()]
    |> Enum.zip()
    |> Enum.map(&segment_on/1)
    |> List.flatten()
  end

  defp check_4_elements(char_list) when length(char_list) > 4, do: char_list |> Enum.take(4)
  defp check_4_elements(char_list) when length(char_list) == 4, do: char_list

  defp check_4_elements(char_list) do
    space_char = Font.segments(" ")

    case length(char_list) do
      3 -> char_list ++ space_char
      2 -> char_list ++ space_char ++ space_char
      1 -> char_list ++ space_char ++ space_char ++ space_char
    end
  end

  defp segment_on({position, segment}), do: <<position, segment>>
end
