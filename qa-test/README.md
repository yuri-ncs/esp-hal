# `qa-test`

This package contains a number of binary applications intended for manual/quality-assurance testing.

Each device has its own unique set of peripherals, and as such not every test will run on every device. We recommend building and flashing the tests using the `xtask` method documented below, which will greatly simplify the process.

To check if a device is compatible with a given test, check the metadata comments above the imports, which will list all supported devices following the `//% CHIPS:` designator. If this metadata is not present, then the test will work on any device supported by `esp-hal`.

As previously stated, we use the [cargo-xtask] pattern for automation. Commands invoking this tool must be run from the root of the repository.

[cargo-xtask]: https://github.com/matklad/cargo-xtask

## Building Tests

You can build all examples for a given device using the `build-examples` subcommand:

```shell
cargo xtask build-examples qa-test esp32
```

Note that we must specify which package to build the tests for, since this repository contains multiple packages.

## Running Tests

You can also build and then subsequently flash and run an test using the `run-example` subcommand. With a target device connected to your host system, run:

```shell
cargo xtask run-example qa-test esp32c6 hello_world
```

Again, note that we must specify which package to build the test from, plus which test to build and flash to the target device.

## Adding Tests

If you are contributing to `esp-hal` and would like to add an test, the process is generally the same as any other project.

One major difference in our case is the metadata comments which state the compatible devices and required features for an test. Both of these designators are optional; if `//% CHIPS:` is omitted then all devices considered to be supported, and if `//% FEATURES:` is omitted then no features are enabled at build time.

To demonstrated, in `src/bin/embassy_hello_world.rs` you will see the following:

```rust
//% CHIPS: esp32 esp32c2 esp32c3 esp32c6 esp32h2 esp32s2 esp32s3
//% FEATURES: embassy esp-hal-embassy/integrated-timers
```

Another thing to be aware of is the GPIO pins being used. We have tried to use pins available the DevKit-C boards from Espressif, however this is being done on a best-effort basis.

In general, the following GPIO are recommended for use, though be conscious of whether certain pins are used for UART, strapping pins, etc. on some devices:

- GPIO0
- GPIO1
- GPIO2
- GPIO3
- GPIO4
- GPIO5
- GPIO8
- GPIO9
- GPIO10
