defmodule Ht16k33Multi.MultiDevices do
  @moduledoc """
  Provides functionality for writing to multiple 7-segment displays at once.

  This module handles the coordination and distribution of characters across multiple `Ht16k33` 7-segment displays.
  It allows you to split a string into segments that can be shown on multiple displays.
  It is especially useful when you want to render full words or sentences across a chain of displays connected
  via I2C, each capable of showing up to 4 characters.


  ## Usage

    > 💡 To simplify usage, please use the `Ht16k33Multi` GenServer module,
    such as calling `Ht16k33Multi.write_to_all/3` for ease of interaction.


  Each display should be started with a unique name using `Ht16k33Multi.start_link(name: :device_name)`.
  You can then pass a list of these device names to `split_for_devices/3` to split a string and map it to the appropriate display.

  Example:

      iex> Ht16k33Multi.MultiDevices.split_for_devices("Hola que tal?", [:blue_leds, :red_leds, :green_leds])
      [blue_leds: "Hola", red_leds: "que", green_leds: "tal?"]

  The resulting keyword list can be piped into display writing functions:

      iex> Ht16k33Multi.MultiDevices.split_for_devices("Hola que tal?", [:blue_leds, :red_leds, :green_leds])
      |> Enum.map(fn {device, chars} -> Ht16k33Multi.write(chars, device) end)
  """
  @moduledoc since: "0.1.0"

  @doc """
  Splits the given character string into chunks and builds a keyword list
  mapping each device name to a segment of characters.

    - `characters`: A string to be displayed across multiple devices.
    - `devices_names`: A list of GenServer names, as passed to `Ht16k33Multi.start_link/1`.
    - `options`: Currently supports:
      - `:one_word_per_display` (default: `true`): If true, splits the string into words (max 4 characters each).
        If false, the string is split into 4-character chunks continuously.

    > 💡 **Note:** Each display supports up to 4 characters. If more chunks than device names are present,
    extra chunks will be ignored. If fewer chunks are provided, blank segments will be appended.

  ## Examples

      iex> Ht16k33Multi.MultiDevices.split_for_devices("Hola que tal?", [:blue_leds, :red_leds, :green_leds])
      [blue_leds: "Hola", red_leds: "que", green_leds: "tal?"]
  """
  @doc since: "0.1.0"
  @spec split_for_devices(String.t(), list(), keyword()) :: keyword()
  def split_for_devices(characters, devices_names, options \\ []) do
    one_word_per_display = Keyword.get(options, :one_word_per_display, true)

    chunks = if one_word_per_display, do: split_words(characters), else: split_every_4(characters)

    joint(devices_names, chunks)
  end

  defp split_words(string), do: string |> String.split(" ", trim: true) |> only_4_chars_per_word()

  defp only_4_chars_per_word(words),
    do: words |> Enum.map(fn word -> String.slice(word, 0..3//1) end)

  defp split_every_4(string) do
    string |> String.codepoints() |> Enum.chunk_every(4) |> Enum.map(&Enum.join/1)
  end

  defp joint(devices_names, chunks) when length(devices_names) == length(chunks),
    do: devices_names |> Enum.zip(chunks)

  defp joint(devices_names, chunks) when length(devices_names) < length(chunks),
    do: joint(devices_names, chunks |> Enum.take(length(devices_names)))

  defp joint(devices_names, chunks), do: joint(devices_names, chunks ++ ["    "])
end
