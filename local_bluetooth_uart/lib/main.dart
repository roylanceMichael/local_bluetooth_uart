import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'src/ble_dealer.dart';
import 'src/ble_player.dart';
import 'src/native/simplecble_bindings.dart';

void main() {
  runApp(const PokerBleApp());
}

class PokerBleApp extends StatelessWidget {
  const PokerBleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Poker Stress Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  BleDealer? _dealer;
  BlePlayer? _player;
  SimpleCbleBindings? _bindings;
  String _status = "Idle";
  bool _isNativeLoaded = false;

  @override
  void initState() {
    super.initState();
    _tryLoadBindings();
  }

  void _tryLoadBindings() {
    try {
      _bindings = SimpleCbleBindings();
      setState(() {
        _isNativeLoaded = true;
        _status = "Native bindings loaded successfully.";
      });
    } catch (e) {
      setState(() {
        _isNativeLoaded = false;
        _status = "Failed to load native bindings. Ensure SimpleBLE is compiled and linked.\nError: $e";
      });
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      setState(() {
        _status = "Bluetooth/Location permissions are required to scan/advertise.";
      });
      return false;
    }
    return true;
  }

  Future<void> _startDealer() async {
    if (_bindings == null) return;
    if (!await _requestPermissions()) return;
    
    setState(() => _status = "Starting Dealer (Central)...");
    
    _player?.stop();
    _player = null;

    _dealer ??= BleDealer(_bindings!);
    _dealer!.start();
    
    setState(() => _status = "Dealer Active. Pulsing 200 bytes every 100ms.");
  }

  Future<void> _startPlayer() async {
    if (_bindings == null) return;
    if (!await _requestPermissions()) return;
    
    setState(() => _status = "Starting Player (Peripheral)...");

    _dealer?.stop();
    _dealer = null;

    _player ??= BlePlayer(_bindings!);
    _player!.start();
    
    setState(() => _status = "Player Active. Waiting for connections...");
  }

  @override
  void dispose() {
    _dealer?.stop();
    _player?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Poker Stress Test')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isNativeLoaded ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                border: Border.all(color: _isNativeLoaded ? Colors.green : Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_status, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isNativeLoaded ? _startDealer : null,
                  icon: const Icon(Icons.cell_tower),
                  label: const Text("Run as DEALER"),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                ),
                ElevatedButton.icon(
                  onPressed: _isNativeLoaded ? _startPlayer : null,
                  icon: const Icon(Icons.smartphone),
                  label: const Text("Run as PLAYER"),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            if (_player != null) Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Player Metrics", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(),
                      StreamBuilder<PlayerMetrics>(
                        stream: _player!.metrics,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text("Waiting for data...");
                          final metrics = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Packets/sec: ${metrics.pps.toStringAsFixed(1)}", style: const TextStyle(fontSize: 18)),
                              const SizedBox(height: 8),
                              Text("Avg Latency: ${metrics.avgLatencyMs.toStringAsFixed(2)} ms", style: const TextStyle(fontSize: 18)),
                            ],
                          );
                        }
                      )
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
