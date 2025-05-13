defmodule Ht16k33Multi.I2cBus do
  @moduledoc """
  Provides a simplified interface for sending I2C messages to the `Ht16k33` display driver.

  This module abstracts away low-level I2C interactions and provides helper functions to
  open a bus and write commands using the `%Ht16k33Multi{}` struct.

  ## Background

  The `Ht16k33` chip receives binary commands over the I2C bus to control LED displays such
  as 7-segment digits. Each command consists of a position address and a segment value.

  ### Manual Command Example

  To display the character "A" manually via `Circuits.I2C`:

      iex> i2c_bus = "i2c-1"
      iex> address = 0x70
      iex> position = 0x00
      iex> command = 0x77 # Segment pattern for "A"
      iex> {:ok, i2c_ref} = Circuits.I2C.open(i2c_bus)
      iex> Circuits.I2C.write(i2c_ref, address, <<position, command>>)

  You can inspect available buses and devices:

      iex> Circuits.I2C.bus_names()
      ["i2c-1"]

      iex> Circuits.I2C.detect_devices()
      Devices on I2C bus "i2c-1":
      * 112 (0x70)

  > 💡 **Note**: Displays must be initialized before writing. See `Ht16k33Multi.Display.initialize/0`.

  ## Using This Module

  This module streamlines communication by accepting bitstrings, integers, or lists of commands:

      iex> {:ok, i2c_ref} = Ht16k33Multi.I2cBus.open("i2c-1")
      iex> ht16k33 = %Ht16k33Multi{address: 0x70, i2c_ref: i2c_ref}
      iex> Ht16k33Multi.I2cBus.write(<<0x00, 0x77>>, ht16k33)

  The latest command and status are stored in the `:last_command` field of the struct.
  """
  @moduledoc since: "0.1.0"

  alias Ht16k33Multi
  alias Circuits.I2C

  defstruct command: nil, exit_status: nil

  @doc """
  Opens the specified I2C bus.

  This function uses Circuits.I2C.open/1 to establish a connection to the
  I2C bus identified by i2c_bus.

  * `i2c_bus` - The name of the I2C bus to open as a string.

  ## Examples

      iex> Ht16k33Multi.I2cBus.open("i2c-1")
      {:ok, #Reference<...>}

      iex> Ht16k33Multi.I2cBus.open("invalid-bus")
      {:error, :enodev}
  """
  @doc since: "0.1.0"
  @spec open(String.t()) :: {:error, any()} | {:ok, reference()}
  def open(i2c_bus), do: I2C.open(i2c_bus)

  @doc """
  Writes a command or a series of commands to the Ht16k33 device.

  This function sends data over the I2C bus to the Ht16k33 device specified
  in the `%Ht16k33{}` struct. It can handle single byte commands, multi-byte
  commands as bitstrings, or a list of commands to be sent sequentially.

  The `%Ht16k33{}` struct is expected to contain the I2C device reference
  (obtained from open/1) and the I2C address of the Ht16k33 device.

  * `command` - The command(s) to send to the device
     as a `bitstring()`, `integer()`, or a `list()` of `bitstring()`s or `integer()`s.
  * `ht16k33` - The `%Ht16k33Multi{}` struct containing
    the I2C device reference and the device address.

  It returns the updated `%Ht16k33Multi{}` struct with the command that was sent
  and the exit_status of the write operation:

    > 💡 **Note**: The display needs to be initialized before anything can be shown.
    For initialization instructions, please refer to the documentation for `Ht16k33Multi.Display.initialize/0`.

  ## Examples

  Sending a single byte command:

      iex> {:ok, i2c_ref} = Ht16k33Multi.I2cBus.open("i2c-1")
      iex> ht16k33 = %Ht16k33Multi{address: 0x70, i2c_ref: i2c_ref}
      iex> Ht16k33Multi.I2cBus.write(0x81, ht16k33) # Example: Trun on the display
      %Ht16k33Multi{address: 0x70, command: <<129>>, exit_status: :ok, i2c_ref: #Reference<...>}

  Sending a multi-byte command as a bitstring:

      iex> {:ok, i2c_ref} = Ht16k33Multi.I2cBus.open("i2c-1")
      iex> ht16k33 = %Ht16k33Multi{address: 0x70, i2c_ref: i2c_ref}
      iex> Ht16k33Multi.I2cBus.write(<<0x00, 0x77>>, ht16k33) # Example: Display "A" at position 0
      %Ht16k33Multi{address: 0x70, command: <<0, 119>>, exit_status: :ok, i2c_ref: #Reference<...>}

  Sending a list of commands:

      iex> {:ok, i2c_ref} = Ht16k33Multi.I2cBus.open("i2c-1")
      iex> ht16k33 = %Ht16k33Multi{address: 0x70, i2c_ref: i2c_ref}
      iex> commands = [0x81, <<0x00, 0x77>>]
      iex> Ht16k33Multi.I2cBus.write(commands, ht16k33)
      %Ht16k33Multi{address: 0x70, command: <<0, 119>>, exit_status: :ok, i2c_ref: #Reference<...>}
  """
  @doc since: "0.1.0"
  @spec write(bitstring() | integer() | maybe_improper_list(), %Ht16k33Multi{}) :: %Ht16k33Multi{}
  def write(command, %Ht16k33Multi{} = ht16k33) when is_bitstring(command),
    do: execute(command, ht16k33)

  def write(command, %Ht16k33Multi{} = ht16k33) when is_integer(command),
    do: execute(<<command>>, ht16k33)

  def write(commands, %Ht16k33Multi{} = ht16k33) when is_list(commands),
    do: commands |> Enum.map(&write(&1, ht16k33)) |> List.last()

  defp execute(command_bitstring, ht16k33) when is_bitstring(command_bitstring) do
    %Ht16k33Multi{i2c_ref: i2c_ref, address: address} = ht16k33

    ht16k33
    |> struct!(
      last_command: %__MODULE__{
        command: command_bitstring,
        exit_status: I2C.write(i2c_ref, address, command_bitstring)
      }
    )
  end
end
