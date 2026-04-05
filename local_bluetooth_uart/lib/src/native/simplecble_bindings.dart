import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// ignore_for_file: camel_case_types, non_constant_identifier_names

typedef simplecble_central_t = ffi.Pointer<ffi.Void>;
typedef simplecble_peripheral_t = ffi.Pointer<ffi.Void>;

typedef simplecble_on_peripheral_found_t = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(simplecble_central_t, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>;

typedef simplecble_on_data_received_t = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(simplecble_peripheral_t, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<ffi.Uint8>, ffi.Size)>>;

typedef simplecble_on_connection_event_t = ffi.Pointer<
    ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Bool)>>;

class SimpleCbleBindings {
  late final ffi.DynamicLibrary _dylib;

  SimpleCbleBindings() {
    _dylib = ffi.DynamicLibrary.open('libsimplecble.dylib'); // Adjust for platform
  }

  late final simplecble_central_create = _dylib
      .lookupFunction<simplecble_central_t Function(), simplecble_central_t Function()>(
          'simplecble_central_create');

  late final simplecble_central_destroy = _dylib.lookupFunction<
      ffi.Void Function(simplecble_central_t),
      void Function(simplecble_central_t)>('simplecble_central_destroy');

  late final simplecble_central_start_scan = _dylib.lookupFunction<
      ffi.Bool Function(simplecble_central_t, ffi.Pointer<Utf8>),
      bool Function(simplecble_central_t, ffi.Pointer<Utf8>)>('simplecble_central_start_scan');

  late final simplecble_central_set_on_peripheral_found = _dylib.lookupFunction<
      ffi.Void Function(simplecble_central_t, simplecble_on_peripheral_found_t),
      void Function(simplecble_central_t, simplecble_on_peripheral_found_t)>('simplecble_central_set_on_peripheral_found');

  late final simplecble_central_connect = _dylib.lookupFunction<
      ffi.Bool Function(simplecble_central_t, ffi.Pointer<Utf8>),
      bool Function(simplecble_central_t, ffi.Pointer<Utf8>)>('simplecble_central_connect');

  late final simplecble_central_write_command = _dylib.lookupFunction<
      ffi.Bool Function(simplecble_central_t, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>,
          ffi.Pointer<Utf8>, ffi.Pointer<ffi.Uint8>, ffi.Size),
      bool Function(simplecble_central_t, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>,
          ffi.Pointer<Utf8>, ffi.Pointer<ffi.Uint8>, int)>('simplecble_central_write_command');

  late final simplecble_peripheral_create = _dylib.lookupFunction<
      simplecble_peripheral_t Function(),
      simplecble_peripheral_t Function()>('simplecble_peripheral_create');

  late final simplecble_peripheral_start_advertising = _dylib.lookupFunction<
      ffi.Bool Function(simplecble_peripheral_t, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>),
      bool Function(simplecble_peripheral_t, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>('simplecble_peripheral_start_advertising');

  late final simplecble_set_on_connection_event = _dylib.lookupFunction<
      ffi.Void Function(simplecble_on_connection_event_t),
      void Function(simplecble_on_connection_event_t)>('simplecble_set_on_connection_event');
}
