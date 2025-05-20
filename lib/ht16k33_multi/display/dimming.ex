defmodule Ht16k33Multi.Display.Dimming do
  @moduledoc """
  Module for setting the dimming level (brightness) of the Ht16k33 display.

  The Ht16k33 supports setting the dimming level, but it does not support reading it back.

    > #### use `Ht16k33Multi` {: .tip}
    > To simplify usage, please use the `Ht16k33Multi` GenServer module,
    > such as calling `Ht16k33Multi.dimming(6)` for ease of interaction.

  ### Dimming Command Format

      Dimming command
      --------------------------
           command | pulse width
      set  1 1 1 0   P3 P2 P1 P0
            (0xE)    (0x0 to 0xF)

      Pulse width | Hex value command
      -------------------------------
      1/16duty      <<0xE0>>
      [...]
      16/16duty     <<0xEF>>
  """
  @moduledoc since: "0.1.0"

  @doc """
  Sets the dimming level of the display.

  Accepts values between 1 and 16, where 1 is the lowest brightness and 16 is the highest.
  Values below 1 are clamped to 1, and values above 16 are clamped to 16.
  """
  @doc since: "0.1.0"
  @spec set(integer()) :: <<_::8>>
  def set(value) do
    case value do
      0 -> <<0xE0>>
      1 -> <<0xE0>>
      2 -> <<0xE1>>
      3 -> <<0xE2>>
      4 -> <<0xE3>>
      5 -> <<0xE4>>
      6 -> <<0xE5>>
      7 -> <<0xE6>>
      8 -> <<0xE7>>
      9 -> <<0xE8>>
      10 -> <<0xE9>>
      11 -> <<0xEA>>
      12 -> <<0xEB>>
      13 -> <<0xEC>>
      14 -> <<0xED>>
      15 -> <<0xEE>>
      16 -> <<0xEF>>
      _ -> <<0xEF>>
    end
  end
end
