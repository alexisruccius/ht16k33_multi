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
  def set(value)
  def set(0), do: <<0xE0>>
  def set(1), do: <<0xE0>>
  def set(2), do: <<0xE1>>
  def set(3), do: <<0xE2>>
  def set(4), do: <<0xE3>>
  def set(5), do: <<0xE4>>
  def set(6), do: <<0xE5>>
  def set(7), do: <<0xE6>>
  def set(8), do: <<0xE7>>
  def set(9), do: <<0xE8>>
  def set(10), do: <<0xE9>>
  def set(11), do: <<0xEA>>
  def set(12), do: <<0xEB>>
  def set(13), do: <<0xEC>>
  def set(14), do: <<0xED>>
  def set(15), do: <<0xEE>>
  def set(16), do: <<0xEF>>
  def set(_other), do: <<0xEF>>
end
