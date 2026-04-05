package com.example.local_bluetooth_uart

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    companion object {
        init {
            System.loadLibrary("simplecble")
        }
    }
}
