defmodule Ht16k33Multi do
  @moduledoc """
  `Ht16k33Multi` is a library for controlling one or more `Ht16k33` microchips,
  which are commonly used to drive 7-segment displays, such as these shown below:

  ![Image of Ht16k33 7-segment display](assets/ht16k33multi-7-segment-love-elixir.jpg)


  ## Features

  The main features of `Ht16k33Multi` include:

  - Displaying numbers on a 7-segment display
  - Displaying words using a special 7-segment font
  - Supporting multiple displays (hence the "multi" in the library name).
    You can easily chain multiple `Ht16k33` devices to display full sentences or other content across them.
  - Utilizing the built-in blinking and dimming features of the `Ht16k33` microchip


  ## Usage

  A typical setup involves using the `Ht16k33` with a 7-segment display and a Raspberry Pi — such as the Raspberry Pi Zero.

  You can use the [Nerves Project](https://hexdocs.pm/nerves/getting-started.html)
  to build firmware for the Raspberry Pi and other embedded systems like the BeagleBone.
  See the [list of supported targets](https://hexdocs.pm/nerves/supported-targets.html) (Nerves Project) for more information.

  ## Installation

  1. **Connect the `Ht16k33` to your embedded system**.
    See the [Connect the device to the I²C bus and power](#module-connect-the-device-to-the-i2c-bus-and-power) section for details.

  2. **Add the library to your dependencies**

      ```elixir
      # mix.exs
      defp deps do
        [
          {:ht16k33_multi, "~> 0.2.2"}
        ]
      end
      ```

  3. **Fetch the dependencies**

      ```shell
      mix deps.get
      ```

  4. **Start the `Ht16k33Multi` GenServer**

      You can start it manually in `iex`:

      ```elixir
      iex> Ht16k33Multi.start_link()
      ```

      Or supervise it within your application:

      ```elixir
      children = [
        # Single device with default I²C bus ("i2c-1") and address (0x70)
        Ht16k33Multi,

        # OR with explicit options
        {Ht16k33Multi, i2c_bus: "i2c-1", address: 0x70}
      ]
      ```

      If you're using multiple devices (all on the default I²C bus `"i2c-1"`), assign each a name and address:

      ```elixir
      children = [
        {Ht16k33Multi, name: :red_leds, address: 0x70},
        {Ht16k33Multi, name: :blue_leds, address: 0x71},
        {Ht16k33Multi, name: :yellow_leds, address: 0x72}
      ]
      ```

      > #### Detect I2C Bus and Device Address {: .tip}
      > See the [Device Address](#module-device-address) section to learn how to detect your I²C bus and device address.


  5. **Write to the display**

      Display a message:

      ```elixir
      iex> Ht16k33Multi.write("Hola")
      ```

      Enable blinking:

      ```elixir
      iex> Ht16k33Multi.blinking_on()
      ```

      Dim the display:

      ```elixir
      iex> Ht16k33Multi.dimming(6)
      ```


  ## Connect the Device to the I2C Bus and Power

  ### Using Qwiic with a Raspberry Pi Zero (rpi0)

  You can easily chain multiple `Ht16k33` devices using Qwiic cables. This allows you to have multiple displays showing full sentences or other content.

  ### Wiring Overview:

  | Wire Color | Function           | Raspberry Pi Zero Pin | GPIO Pin  |
  |------------|--------------------|-----------------------|-----------|
  | Black      | GND                | 6                     | GND       |
  | Red        | 3.3V               | 4                     | 5V        |
  | Blue       | SDA (Serial Data)  | 3                     | GPIO2     |
  | Yellow     | SCL (Serial Clock) | 5                     | GPIO3     |


  ![HT16K33 7-segment display with I²C Qwiic connection to a Raspberry Pi Zero](assets/ht16k33-7-segment-i2c-qwiic-connection-to-rpi0.jpg)

  ## Device Address

  You can detect the I²C bus and device addresses using [`Circuits.I2C`](https://hexdocs.pm/circuits_i2c/Circuits.I2C.html):

  ```elixir
  iex> Circuits.I2C.bus_names()
  ["i2c-1"]

  iex> Circuits.I2C.detect_devices()
  Devices on I2C bus "i2c-1":
  * 112  (0x70)
  1 devices detected on 1 I²C buses
  ```

  The device address is configurable in hardware.
  You can set it by soldering the address pins (shown at the bottom right in the image below).

  See the [HT16K33 datasheet](https://www.holtek.com/webapi/116711/HT16K33Av102.pdf) for more details.

  ![HT16K33 7-segment backside with address pins and I²C Qwiic connection](assets/ht16k33-backside.jpg)

  ## Testing

  This library has been tested with the **Adafruit 7-Segment LED HT16K33 Backpack**.
  """
  @moduledoc since: "0.1.0"

  use GenServer

  alias Ht16k33Multi.{Display, I2cBus, MultiDevices, Write}

  defstruct name: nil, i2c_ref: nil, address: nil, last_command: %I2cBus{}

  @i2c_bus "i2c-1"
  @address 0x70

  def child_spec(options) do
    %{id: Keyword.get(options, :name, __MODULE__), start: {__MODULE__, :start_link, [options]}}
  end

  @doc """
  Starts the `Ht16k33Multi` GenServer.

  ## Options

    * `:name` – (optional) The GenServer name of the device.
      Use this to run multiple GenServers for different LED displays.

    * `:i2c_bus` – The name of the I²C bus (e.g., `"i2c-1"`).
      Defaults to `"i2c-1"`.

    * `:address` – The I²C address of the device (e.g., `0x70`).
      Defaults to `0x70`.

  ## Default values

  ```elixir
  name: Ht16k33Multi,
  i2c_bus: "i2c-1",
  address: 0x70
  ```

  ## Examples

  Start with defaults:

  ```elixir
  Ht16k33Multi.start_link()
  ```

  Start with custom name and address:

  ```elixir
  Ht16k33Multi.start_link(name: :red_leds, address: 0x72)
  ```
  """
  @doc since: "0.1.0"
  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(options \\ []) do
    name = Keyword.get(options, :name, __MODULE__)
    i2c_bus = Keyword.get(options, :i2c_bus, @i2c_bus)
    address = Keyword.get(options, :address, @address)

    GenServer.start_link(__MODULE__, {name, i2c_bus, address}, name: name)
  end

  @doc """
  Returns the current state of the `Ht16k33Multi` GenServer.

    * `name` – The GenServer name, PID, or tuple identifying the process.
      This should match the name provided when starting the GenServer with `Ht16k33Multi.start_link/1`.

  ## Examples

  ```elixir
  Ht16k33Multi.status()
  Ht16k33Multi.status(:red_leds)
  ```
  """
  @doc since: "0.1.0"
  @spec status(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: %Ht16k33Multi{}
  def status(name \\ __MODULE__), do: GenServer.call(name, :status)

  @doc """
  Writes a string or integer to the 7-segment display.

  You can pass more than 4 characters or digits,
  but only the first 4 will be shown since the display has just 4 positions.

    * `characters` – A string or integer to display.
    * `name` – The GenServer name of the device.
      This should match the name provided to `Ht16k33Multi.start_link/1`,
      e.g., `Ht16k33Multi.start_link(name: :red_leds)`.

  ## Examples

      Ht16k33Multi.write("Hola")
      Ht16k33Multi.write(43, :red_leds)
  """
  @doc since: "0.1.0"
  @spec write(any(), atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def write(characters, name \\ __MODULE__), do: GenServer.cast(name, {:write, characters})

  @doc """
  Writes a string of characters or an integer to multiple 7-segment displays.

    * `characters` – A binary (string) or integer to display.
    * `devices_names` – A list of GenServer names that identify the displays.
      These names should match those provided to `Ht16k33Multi.start_link/1`,
      e.g., `[:blue_leds, :red_leds]`.
    * `option` – An optional keyword list of options.
      Use `one_word_per_display: false` if you want to display characters continuously across all displays.

  By default, one word (up to 4 characters) is written per display.
  Words longer than 4 characters will be truncated.

  If you want to display the characters continuously across displays,
  pass the option `one_word_per_display: false`.

  ## Example

      Ht16k33Multi.write_to_all("Hola que tal?", [:blue_leds, :red_leds, :yellow_leds])
  """
  @doc since: "0.1.0"
  @spec write_to_all(binary(), list(), keyword()) :: list()
  def write_to_all(characters, devices_names, option \\ []) do
    MultiDevices.split_for_devices(characters, devices_names, option)
    |> Enum.map(fn {device, word} -> Ht16k33Multi.write(word, device) end)
  end

  @doc """
  Turns blinking on for the 7-segment display.

  The default blinking speed is 0.5 Hz.

  * `speed` – The blinking speed:
      * `0` – 0.5 Hz
      * `1` – 1 Hz
      * `2` – 2 Hz
  * `name` – The GenServer name of the device.
    This should match the name provided to `Ht16k33Multi.start_link/1`,
    e.g., `Ht16k33Multi.start_link(name: :red_leds)`.

  ## Example

      Ht16k33Multi.blinking_on(:red_leds, 1)
  """
  @doc since: "0.1.0"
  @spec blinking_on(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any()) :: :ok
  def blinking_on(name \\ __MODULE__, speed \\ 0),
    do: GenServer.cast(name, {:blinking_on, speed})

  @doc """
  Sets blinking on for all displays.

    * `devices_names` – A list of GenServer names that identify the displays.
      These names should match those provided to `Ht16k33Multi.start_link/1`,
      e.g., `[:blue_leds, :red_leds]`.
    * `speed` – The blinking speed.
      Refer to `blinking_on/2` for available speed values.

  This function calls `blinking_on/2` for each device in the list,
  setting the blinking on for all of them.

  ## Examples

      Ht16k33Multi.blinking_on_all([:blue_leds, :red_leds], 1)
  """
  @doc since: "0.1.0"
  @spec blinking_on_all(any(), any()) :: list()
  def blinking_on_all(devices_names, speed \\ 0) do
    devices_names |> Enum.map(fn device -> Ht16k33Multi.blinking_on(device, speed) end)
  end

  @doc """
  Sets blinking off for the 7-segment display.

    * `name` – The GenServer name of the device.
      This should match the name provided to `Ht16k33Multi.start_link/1`,
      e.g., `Ht16k33Multi.start_link(name: :red_leds)`.

  ## Examples

      Ht16k33Multi.blinking_off(:red_leds)
  """
  @doc since: "0.1.0"
  @spec blinking_off(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def blinking_off(name \\ __MODULE__), do: GenServer.cast(name, :blinking_off)

  @doc """
  Sets blinking off for all displays.

    * `devices_names` – A list of GenServer names that identify the displays.
      These names should match those provided to `Ht16k33Multi.start_link/1`,
      e.g., `[:blue_leds, :red_leds]`.

  This function calls `blinking_off/1` for each device in the list,
  setting the blinking off for all of them.

  ## Examples

      Ht16k33Multi.blinking_off_all([:blue_leds, :red_leds])
  """
  @doc since: "0.1.0"
  @spec blinking_off_all(any()) :: list()
  def blinking_off_all(devices_names) do
    devices_names |> Enum.map(fn device -> Ht16k33Multi.blinking_off(device) end)
  end

  @doc """
  Sets the dimming level (brightness) of the display.

  The `value` should be an integer between 1 and 16.

    * `value` – The dimming level. Must be an integer between 1 and 16.
    * `name` – The GenServer name of the device.
      This should match the name provided to `Ht16k33Multi.start_link/1`,
      e.g., `Ht16k33Multi.start_link(name: :red_leds)`.

  ## Examples

      Ht16k33Multi.dimming(8, :red_leds)
  """
  @doc since: "0.1.0"
  @spec dimming(any(), atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def dimming(value, name \\ __MODULE__), do: GenServer.cast(name, {:dimming, value})

  @doc """
  Dims all displays with the same value.

  The `value` should be an integer between 1 and 16.

    * `value` – The dimming level. Must be an integer between 1 and 16.
    * `devices_names` – A list of GenServer names that identify the displays.
      These names should match those provided to `Ht16k33Multi.start_link/1`,
      e.g., `[:blue_leds, :red_leds]`.

  This function calls `dimming/2` for each device in the list,
  setting the dimming level for all of them.

  ## Examples

      Ht16k33Multi.dimming_all(8, [:blue_leds, :red_leds])
  """
  @doc since: "0.1.0"
  @spec dimming_all(any(), any()) :: list()
  def dimming_all(value, devices_names) do
    devices_names |> Enum.map(fn device -> Ht16k33Multi.dimming(value, device) end)
  end

  @doc """
  Sets colon on for the 7-segment display.

    * `name` – The GenServer name of the device.
      This should match the name provided to `Ht16k33Multi.start_link/1`,
      e.g., `Ht16k33Multi.start_link(name: :red_leds)`.

  ## Examples

      Ht16k33Multi.colon_on(:red_leds)
  """
  @doc since: "0.2.0"
  @spec colon_on(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def colon_on(name \\ __MODULE__), do: GenServer.cast(name, :colon_on)

  @doc """
  Sets colon on for all displays.

    * `devices_names` – A list of GenServer names that identify the displays.
      These names should match those provided to `Ht16k33Multi.start_link/1`,
      e.g., `[:blue_leds, :red_leds]`.

  This function calls `colon_on/1` for each device in the list,
  setting the colon on for all of them.

  ## Examples

      Ht16k33Multi.colon_on_all([:blue_leds, :red_leds])
  """
  @doc since: "0.2.0"
  @spec colon_on_all(any()) :: list()
  def colon_on_all(devices_names),
    do: devices_names |> Enum.map(fn device -> Ht16k33Multi.colon_on(device) end)

  @doc """
  Sets colon off for the 7-segment display.

    * `name` – The GenServer name of the device.
      This should match the name provided to `Ht16k33Multi.start_link/1`,
      e.g., `Ht16k33Multi.start_link(name: :red_leds)`.

  ## Examples

      Ht16k33Multi.colon_off(:red_leds)
  """
  @doc since: "0.2.0"
  @spec colon_off(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def colon_off(name \\ __MODULE__), do: GenServer.cast(name, :colon_off)

  @doc """
  Sets colon off for all displays.

    * `devices_names` – A list of GenServer names that identify the displays.
      These names should match those provided to `Ht16k33Multi.start_link/1`,
      e.g., `[:blue_leds, :red_leds]`.

  This function calls `colon_off/1` for each device in the list,
  setting the colon off for all of them.

  ## Examples

      Ht16k33Multi.colon_off_all([:blue_leds, :red_leds])
  """
  @doc since: "0.2.0"
  @spec colon_off_all(any()) :: list()
  def colon_off_all(devices_names),
    do: devices_names |> Enum.map(fn device -> Ht16k33Multi.colon_off(device) end)

  # server callbacks

  @impl true
  def init({name, i2c_bus, address}) do
    {:ok, i2c_ref} = I2cBus.open(i2c_bus)
    ht16k33 = %__MODULE__{name: name, i2c_ref: i2c_ref, address: address}

    {:ok, Display.initialize() |> I2cBus.write(ht16k33)}
  end

  @impl true
  def handle_call(:status, _from, %__MODULE__{} = ht16k33), do: {:reply, ht16k33, ht16k33}

  @impl true
  def handle_cast({:write, characters}, %__MODULE__{} = ht16k33) do
    Display.clear() |> I2cBus.write(ht16k33)
    {:noreply, Write.to_display(characters) |> I2cBus.write(ht16k33)}
  end

  @impl true
  def handle_cast({:blinking_on, speed}, %__MODULE__{} = ht16k33),
    do: {:noreply, Display.blinking_on(speed) |> I2cBus.write(ht16k33)}

  @impl true
  def handle_cast(:blinking_off, %__MODULE__{} = ht16k33),
    do: {:noreply, Display.blinking_off() |> I2cBus.write(ht16k33)}

  @impl true
  def handle_cast({:dimming, value}, %__MODULE__{} = ht16k33),
    do: {:noreply, Display.Dimming.set(value) |> I2cBus.write(ht16k33)}

  @impl true
  def handle_cast(:colon_on, %__MODULE__{} = ht16k33),
    do: {:noreply, Display.colon_on() |> I2cBus.write(ht16k33)}

  @impl true
  def handle_cast(:colon_off, %__MODULE__{} = ht16k33),
    do: {:noreply, Display.colon_off() |> I2cBus.write(ht16k33)}
end
