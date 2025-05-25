# Changelog

## v0.2.1 (2025-05-24)

### Fixed

- Fixed a bug where the initial `Ht16k33Multi.init/0` GenServer start did not clear all LED segments.
The display now correctly initializes via `Display.initialize().`


## v0.2.0 (2025-05-19)

### Enhancements

- `colon_on/1`: Enables the colon LED on a specific display.
- `colon_off/1`: Disables the colon LED on a specific display.
- `colon_on_all/1`: Enables the colon LED on all connected displays.
- `colon_off_all/1`: Disables the colon LED on all connected displays.

These new functions make it easier to control the colon segment on HT16K33-driven 7-segment displays, useful for time layouts.

---

For full documentation and usage examples, visit [HexDocs](https://hexdocs.pm/ht16k33_multi)
