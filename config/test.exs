import Config

alias Ht16k33Multi.CircuitSimMock.Ht16k33Mock

# for simulating a circuits device
config :circuits_i2c, default_backend: CircuitsSim.I2C.Backend

# own circuits device simulation
config :circuits_sim,
  config: [
    {Ht16k33Mock, bus_name: "i2c-1", address: 0x70},
    {Ht16k33Mock, bus_name: "i2c-1", address: 0x71},
    {Ht16k33Mock, bus_name: "i2c-1", address: 0x72}
  ]
