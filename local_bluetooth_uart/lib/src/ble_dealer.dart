import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'native/simplecble_bindings.dart';

class BleDealer {
  final SimpleCbleBindings _bindings;
  late final simplecble_central_t _central;
  final Map<String, String> _connections = {}; // Address -> Identifier
  Timer? _pulseTimer;
  final String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // UART Service
  final String txCharUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // RX on peripheral

  BleDealer(this._bindings) {
    _central = _bindings.simplecble_central_create();
    _setupCallbacks();
  }

  void _setupCallbacks() {
    // NativeCallable is available in recent Dart versions for async callbacks
    final onFound = NativeCallable<
        Void Function(simplecble_central_t, Pointer<Utf8>,
            Pointer<Utf8>)>.isolateLocal(_onPeripheralFound);
    _bindings.simplecble_central_set_on_peripheral_found(_central, onFound.nativeFunction);

    final onEvent = NativeCallable<
        Void Function(Pointer<Utf8>,
            Bool)>.isolateLocal(_onConnectionEvent);
    _bindings.simplecble_set_on_connection_event(onEvent.nativeFunction);
  }

  void _onPeripheralFound(simplecble_central_t central, Pointer<Utf8> idPtr, Pointer<Utf8> addrPtr) {
    final id = idPtr.toDartString();
    final addr = addrPtr.toDartString();
    print("Dealer: Found Peripheral $id at $addr");
    
    if (_connections.length < 8 && !_connections.containsKey(addr)) {
      print("Dealer: Attempting to connect to $addr");
      _bindings.simplecble_central_connect(_central, addr.toNativeUtf8());
    }
  }

  void _onConnectionEvent(Pointer<Utf8> addrPtr, bool connected) {
    final addr = addrPtr.toDartString();
    if (connected) {
      print("Dealer: Connected to $addr");
      _connections[addr] = addr; // Store address
    } else {
      print("Dealer: CONNECTION DROPPED for Peer $addr");
      _connections.remove(addr);
    }
  }

  void start() {
    _bindings.simplecble_central_start_scan(_central, serviceUuid.toNativeUtf8());
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _pulse());
  }

  void _pulse() {
    if (_connections.isEmpty) return;

    final data = Uint8List(200); // 200-byte dummy buffer
    // Fill with some dummy data
    for (var i = 0; i < data.length; i++) {
      data[i] = i % 256;
    }

    final dataPtr = calloc<Uint8>(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);

    for (final addr in _connections.keys) {
      _bindings.simplecble_central_write_command(
        _central,
        addr.toNativeUtf8(),
        serviceUuid.toNativeUtf8(),
        txCharUuid.toNativeUtf8(),
        dataPtr,
        data.length,
      );
    }
    // Note: In production, reuse buffer and avoid toNativeUtf8 in loop
    calloc.free(dataPtr);
  }

  void stop() {
    _pulseTimer?.cancel();
    _bindings.simplecble_central_destroy(_central);
  }
}
