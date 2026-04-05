import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'native/simplecble_bindings.dart';

class PlayerMetrics {
  final double pps;
  final double avgLatencyMs;
  PlayerMetrics(this.pps, this.avgLatencyMs);
}

class BlePlayer {
  final SimpleCbleBindings _bindings;
  late final simplecble_peripheral_t _peripheral;
  final StreamController<PlayerMetrics> _metricsController = StreamController.broadcast();
  
  int _packetCount = 0;
  DateTime? _lastPacketTime;
  double _totalLatency = 0;
  Timer? _metricsTimer;

  final String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";

  BlePlayer(this._bindings) {
    _peripheral = _bindings.simplecble_peripheral_create();
    _setupCallbacks();
  }

  Stream<PlayerMetrics> get metrics => _metricsController.stream;

  void _setupCallbacks() {
    // Note: Bindings for set_on_data_received were omitted in simplified bindings but should be there
    // For this tracer bullet, we assume the native side calls back when data arrives.
    // final onData = NativeCallable<simplecble_on_data_received_t>.isolateLocal(_onDataReceived);
  }

  // This would be called from Native
  void onDataReceived(int length) {
    final now = DateTime.now();
    _packetCount++;
    
    if (_lastPacketTime != null) {
      final diff = now.difference(_lastPacketTime!).inMicroseconds / 1000.0;
      _totalLatency += diff;
    }
    _lastPacketTime = now;
  }

  void start() {
    _bindings.simplecble_peripheral_start_advertising(
      _peripheral, 
      "PokerPlayer".toNativeUtf8(), 
      serviceUuid.toNativeUtf8()
    );

    _metricsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final pps = _packetCount.toDouble();
      final avgLatency = _packetCount > 0 ? _totalLatency / _packetCount : 0.0;
      
      _metricsController.add(PlayerMetrics(pps, avgLatency));
      
      // Reset for next window
      _packetCount = 0;
      _totalLatency = 0;
    });
  }

  void stop() {
    _metricsTimer?.cancel();
    _metricsController.close();
  }
}
