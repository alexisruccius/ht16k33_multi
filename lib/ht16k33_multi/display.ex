defmodule Ht16k33Multi.Display do
  @moduledoc """
  Commands for controlling a 7-segment display using the `Ht16k33`.

  For detailed information, refer to the official `Ht16k33` datasheet:
  https://www.holtek.com/webapi/116711/HT16K33Av102.pdf

  These commands must be sent via the I2C bus to interact with the device. For example:

      command = Display.blincking_off()
      Circuits.I2C.write(ref, 0x70, <<command>>)

  or

      Display.blincking_off() |> I2cBus.write(%Ht16k33{} = state)

    > #### use `Ht16k33Multi` {: .tip}
    > To simplify usage, please use the `Ht16k33Multi` GenServer module,
    > such as calling `Ht16k33Multi.blinking_on()` for ease of interaction.

    > #### Display needs to be initialized {: .info}
    > The display needs to be initialized before anything can be shown.
    > For initialization instructions, please refer to the documentation for `Ht16k33Multi.Display.initialize/0`.



  ## Display positions and colon

  The display uses specific positions to control the segments and colon:

  ```
  Position | A   B  :  C  D  |
           |-----------------|
  Display  | 8.  8. :  8. 8. |
  ```


  | Position   | Hex Register |
  |------------|--------------|
  | A          | 0x00         |
  | B          | 0x02         |
  | : (colon)  | 0x04         |
  | C          | 0x06         |
  | D          | 0x08         |
  """
  @moduledoc since: "0.1.0"

  alias Ht16k33Multi.Display.Blinking

  @colon_position 0x04

  @display_positions %{
    "A" => 0x00,
    "B" => 0x02,
    "C" => 0x06,
    "D" => 0x08
  }

  @doc """
  Initialize the display by enabling the oscillation, turning the display on,
  and ensuring the colon is off for a clean display of text.

  This is required to begin displaying something on the `Ht16k33`.
  """
  @doc since: "0.1.0"
  @spec initialize() :: [<<_::16>> | 33 | 129, ...]
  def initialize(), do: [oscillation_on(), display_on(), colon_off()]

  @doc """
  Command to start the oscillation, which is necessary for initialization.
  """
  @doc since: "0.1.0"
  @spec oscillation_on() :: 33
  def oscillation_on(), do: 0x21

  @doc """
  Command to turn the display on.
  """
  @doc since: "0.1.0"
  @spec display_on() :: 129
  def display_on(), do: 0x81

  @doc """
  Command to turn the display off.
  """
  @doc since: "0.1.0"
  @spec display_off() :: 128
  def display_off(), do: 0x80

  @doc """
  Command to turn the colon on.
  """
  @doc since: "0.1.0"
  @spec colon_on() :: <<_::16>>
  def colon_on(), do: <<@colon_position, 0x02>>

  @doc """
  Command to turn the colon off.
  """
  @doc since: "0.1.0"
  @spec colon_off() :: <<_::16>>
  def colon_off(), do: <<@colon_position, 0x00>>

  @doc """
  Retrieve all display position values as a list,
  based on this module documentation (`Ht16k33Multi.Display`).
  """
  @doc since: "0.1.0"
  @spec all_positions() :: list()
  def all_positions(), do: @display_positions |> Map.values()

  @doc """
  Clear the display by turning off all LED segments.
  """
  @doc since: "0.1.0"
  @spec clear() :: binary()
  def clear(), do: (all_positions() |> Enum.map(&clear/1) |> List.to_string()) <> colon_off()
  defp clear(position), do: <<position, 0x00>>

  @doc """
  Command to activate blinking on the display with adjustable speed.

  The default blinking speed is 0.5 Hz.

  * `speed` – The blinking speed:
      * `0` – 0.5 Hz
      * `1` – 1 Hz
      * `2` – 2 Hz
  """
  @doc since: "0.1.0"
  @spec blinking_on(any()) :: 131 | 133 | 135
  def blinking_on(speed \\ 0), do: Blinking.on(speed)

  @doc """
  Command to turn off blinking on the display.
  """
  @doc since: "0.1.0"
  @spec blinking_off() :: 129
  def blinking_off(), do: Blinking.off()
end
