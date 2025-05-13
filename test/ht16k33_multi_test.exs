defmodule Ht16k33MultiTest do
  @moduledoc """
  Defined CircuitSim mocks in config/test.exs for addresses 0x70, 0x71, 0x72
  """
  use ExUnit.Case

  alias Ht16k33Multi
  alias Ht16k33Multi.I2cBus

  setup_all :start_ht16k33_genserver

  defp start_ht16k33_genserver(_context) do
    start_supervised(Ht16k33Multi)
    :ok
  end

  describe "start_link/1" do
    test "multiple Ht16k33 GenServers can be started with different names" do
      start_supervised({Ht16k33Multi, name: :yellow_leds})
      assert %Ht16k33Multi{name: :yellow_leds} = :sys.get_state(:yellow_leds)
    end

    test "multiple Ht16k33 GenServers with different addresses" do
      address = 0x71
      start_supervised({Ht16k33Multi, name: :blue_leds, address: address})
      assert %Ht16k33Multi{name: :blue_leds, address: ^address} = :sys.get_state(:blue_leds)
    end
  end

  describe "child_spec/1" do
    test "multiple GenServers can be started with a Supervisor with child_specs" do
      children = [
        {Ht16k33Multi, name: :red_leds, address: 0x70},
        {Ht16k33Multi, name: :blue_leds, address: 0x71},
        {Ht16k33Multi, name: :yellow_leds, address: 0x72},
        {Ht16k33Multi, name: :green_leds, address: 0x73}
      ]

      {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

      assert %{active: 4, specs: 4, supervisors: 0, workers: 4} = Supervisor.count_children(pid)
    end
  end

  describe "status/1" do
    test "gets the status for different GenServer names" do
      address = 0x70
      start_supervised({Ht16k33Multi, name: :red_leds, address: address})
      assert Ht16k33Multi.status(:red_leds) == :sys.get_state(:red_leds)
    end
  end

  describe "blinking_on/0" do
    test "command should succeed" do
      Ht16k33Multi.blinking_on()

      assert %Ht16k33Multi{last_command: %I2cBus{command: <<0x87>>, exit_status: :ok}} =
               :sys.get_state(Ht16k33Multi)
    end
  end

  describe "blinking_on/1" do
    test "should work for different GenServer names" do
      address = 0x72
      start_supervised({Ht16k33Multi, name: :green_leds, address: address})
      Ht16k33Multi.blinking_on(:green_leds)

      assert %Ht16k33Multi{
               name: :green_leds,
               last_command: %I2cBus{command: <<0x87>>, exit_status: :ok}
             } = :sys.get_state(:green_leds)
    end
  end

  describe "blinking_on/2" do
    test "should work for the different blinking speeds" do
      address = 0x72
      start_supervised({Ht16k33Multi, name: :green_leds, address: address})
      Ht16k33Multi.blinking_on(:green_leds, 1)

      assert %Ht16k33Multi{
               name: :green_leds,
               last_command: %I2cBus{command: <<0x85>>, exit_status: :ok}
             } = :sys.get_state(:green_leds)

      Ht16k33Multi.blinking_on(:green_leds, 2)

      assert %Ht16k33Multi{
               name: :green_leds,
               last_command: %I2cBus{command: <<0x83>>, exit_status: :ok}
             } = :sys.get_state(:green_leds)
    end
  end

  describe "blinking_off/2" do
    test "command should succeed" do
      Ht16k33Multi.blinking_off()

      assert %Ht16k33Multi{last_command: %I2cBus{command: <<0x81>>, exit_status: :ok}} =
               :sys.get_state(Ht16k33Multi)
    end

    test "should work for different GenServer names" do
      address = 0x72
      start_supervised({Ht16k33Multi, name: :green_leds, address: address})
      Ht16k33Multi.blinking_off(:green_leds)

      assert %Ht16k33Multi{
               name: :green_leds,
               last_command: %I2cBus{command: <<0x81>>, exit_status: :ok}
             } = :sys.get_state(:green_leds)
    end
  end

  describe "write/1" do
    test "command should succeed" do
      Ht16k33Multi.write("Hola")
      last_letter_a = <<0x08, 0x77>>

      assert %Ht16k33Multi{last_command: %I2cBus{command: ^last_letter_a, exit_status: :ok}} =
               :sys.get_state(Ht16k33Multi)
    end

    test "should work for different GenServer names" do
      address = 0x72
      start_supervised({Ht16k33Multi, name: :green_leds, address: address})
      Ht16k33Multi.write("Ciao", :green_leds)
      last_letter_o = <<0x08, 0x3F>>

      assert %Ht16k33Multi{
               name: :green_leds,
               last_command: %I2cBus{command: ^last_letter_o, exit_status: :ok}
             } = :sys.get_state(:green_leds)
    end
  end

  describe "write_to_all/3" do
    test "write to three displays" do
      characters = "message for all three displays"
      devices = [:red, :green, :blue]
      devices_address = [red: 0x70, green: 0x71, blue: 0x72]

      for {device, address} <- devices_address do
        start_supervised({Ht16k33Multi, name: device, address: address})
      end

      assert Ht16k33Multi.write_to_all(characters, devices) == [:ok, :ok, :ok]
    end
  end

  describe "dimming/1" do
    test "different dimming settings should succeed" do
      Ht16k33Multi.dimming(4)

      assert %Ht16k33Multi{last_command: %I2cBus{command: <<0xE3>>, exit_status: :ok}} =
               :sys.get_state(Ht16k33Multi)

      Ht16k33Multi.dimming(12)

      assert %Ht16k33Multi{last_command: %I2cBus{command: <<0xEB>>, exit_status: :ok}} =
               :sys.get_state(Ht16k33Multi)
    end

    test "should work for different GenServer names" do
      address = 0x72
      start_supervised({Ht16k33Multi, name: :green_leds, address: address})
      Ht16k33Multi.dimming(4, :green_leds)

      assert %Ht16k33Multi{
               name: :green_leds,
               last_command: %I2cBus{command: <<0xE3>>, exit_status: :ok}
             } = :sys.get_state(:green_leds)
    end
  end

  describe "dimming_all/2" do
    test "write to three displays" do
      value = 4
      devices = [:red, :green, :blue]
      devices_address = [red: 0x70, green: 0x71, blue: 0x72]

      for {device, address} <- devices_address do
        start_supervised({Ht16k33Multi, name: device, address: address})
      end

      assert Ht16k33Multi.dimming_all(value, devices) == [:ok, :ok, :ok]
    end
  end

  describe "blinking_on_all/1" do
    test "write to three displays" do
      devices = [:red, :green, :blue]
      devices_address = [red: 0x70, green: 0x71, blue: 0x72]

      for {device, address} <- devices_address do
        start_supervised({Ht16k33Multi, name: device, address: address})
      end

      assert Ht16k33Multi.blinking_on_all(devices) == [:ok, :ok, :ok]
    end
  end

  describe "blinking_on_all/2" do
    test "write to three displays and set speed" do
      devices = [:red, :green, :blue]
      devices_address = [red: 0x70, green: 0x71, blue: 0x72]

      for {device, address} <- devices_address do
        start_supervised({Ht16k33Multi, name: device, address: address})
      end

      assert Ht16k33Multi.blinking_on_all(devices, 1) == [:ok, :ok, :ok]
    end
  end

  describe "blinking_off_all/1" do
    test "write to three displays" do
      devices = [:red, :green, :blue]
      devices_address = [red: 0x70, green: 0x71, blue: 0x72]

      for {device, address} <- devices_address do
        start_supervised({Ht16k33Multi, name: device, address: address})
      end

      assert Ht16k33Multi.blinking_off_all(devices) == [:ok, :ok, :ok]
    end
  end
end
