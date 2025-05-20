defmodule Ht16k33Multi.Display.Blinking do
  @moduledoc """
  Provides commands to control blinking on the entire display.

  You can enable blinking at different frequencies or disable it entirely.

    > #### use `Ht16k33Multi` {: .tip}
    > To simplify usage, please use the `Ht16k33Multi` GenServer module,
    > such as calling `Ht16k33Multi.blinking_on()` for ease of interaction.
  """
  @moduledoc since: "0.1.0"

  @doc """
  Returns the command to enable blinking at the specified speed.

  The default blinking speed is 0.5 Hz.

  Supported `speed` values:
    * `0` — 0.5 Hz
    * `1` — 1 Hz
    * `2` — 2 Hz
  Any other value defaults to 2 Hz.
  """
  @doc since: "0.1.0"
  @spec on(any()) :: 131 | 133 | 135
  def on(speed \\ 0) do
    case speed do
      0 -> blinking_0_5hz()
      1 -> blinking_1hz()
      _ -> blinking_2hz()
    end
  end

  @doc """
  Returns the command to disable blinking.
  """
  @doc since: "0.1.0"
  @spec off() :: 129
  def off(), do: 0x81

  defp blinking_0_5hz(), do: 0x87
  defp blinking_1hz(), do: 0x85
  defp blinking_2hz(), do: 0x83
end
