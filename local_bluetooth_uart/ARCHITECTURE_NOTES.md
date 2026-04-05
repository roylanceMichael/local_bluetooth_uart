# Architecture Notes: Local Bluetooth UART

## The "SimpleBLE" Limitation
Currently, this project uses **SimpleBLE** via a custom C-wrapper (`simplecble`) and Dart FFI to achieve high-performance, low-latency Bluetooth communication, bypassing standard Flutter plugins.

**CRITICAL LIMITATION:** 
SimpleBLE is officially a **Central-only** library. 
- **The Dealer (Central):** Works perfectly. SimpleBLE provides robust, cross-platform APIs for scanning, connecting, and writing to peripherals at high frequency.
- **The Player (Peripheral):** SimpleBLE does *not* provide cross-platform APIs for advertising as a peripheral or setting up a GATT server (RX/TX characteristics). The current implementation in `src/simplecble.cpp` for the Peripheral role is **stubbed/mocked**.

## Next Steps for the Peripheral (Player) Role
To implement the Player role in this star topology, you must choose one of two paths:

### Path 1: Extend the C++ Wrapper (Native OS APIs)
You will need to write platform-specific C++ or Objective-C code inside `src/simplecble.cpp` (or additional linked files) to implement the Peripheral APIs natively:
- **Windows:** Use WinRT `GattServiceProvider` and `BluetoothLEAdvertisementPublisher` APIs.
- **macOS/iOS:** Use `CoreBluetooth` (`CBPeripheralManager`).
- **Android:** Use JNI to call `BluetoothLeAdvertiser` and `BluetoothGattServer`.
- **Linux:** Use BlueZ DBus APIs (SimpleBLE already uses DBus for the Central role, so you can leverage the existing `simpledbus` dependency).

### Path 2: Hybrid Approach (Recommended for speed of development)
Since the **Dealer** requires the extreme optimization (pulsing 8 clients every 100ms), it benefits most from the FFI approach. The **Player** only needs to advertise itself and receive data.
- Keep the `BleDealer` FFI implementation.
- Replace the `BlePlayer` implementation with a standard Flutter plugin (e.g., `flutter_ble_peripheral` or `bluetooth_low_energy`).
- Let the Flutter plugin handle the boilerplate of advertising the GATT server, as it does not need the same level of aggressive optimization.