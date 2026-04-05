package com.example.local_bluetooth_uart

import io.flutter.embedding.android.FlutterActivity
import org.simpleble.android.bridge.BluetoothGattCallback
import org.simpleble.android.bridge.ScanCallback

class MainActivity: FlutterActivity() {
    companion object {
        init {
            // Force the JVM to load the SimpleBLE bridge classes before the native library
            // tries to resolve them via FindClass during initialization.
            val b = BluetoothGattCallback::class.java
            val s = ScanCallback::class.java
            System.loadLibrary("simplecble")
        }
    }
}
