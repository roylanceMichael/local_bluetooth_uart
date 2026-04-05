#ifndef SIMPLECBLE_H
#define SIMPLECBLE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

typedef void* simplecble_central_t;
typedef void* simplecble_peripheral_t;

// --- Central (Dealer) ---
EXPORT simplecble_central_t simplecble_central_create();
EXPORT void simplecble_central_destroy(simplecble_central_t central);
EXPORT bool simplecble_central_start_scan(simplecble_central_t central, const char* service_uuid);
EXPORT void simplecble_central_stop_scan(simplecble_central_t central);

typedef void (*simplecble_on_peripheral_found_t)(simplecble_central_t central, const char* identifier, const char* address);
EXPORT void simplecble_central_set_on_peripheral_found(simplecble_central_t central, simplecble_on_peripheral_found_t callback);

EXPORT bool simplecble_central_connect(simplecble_central_t central, const char* address);
EXPORT void simplecble_central_disconnect(simplecble_central_t central, const char* address);

EXPORT bool simplecble_central_write_request(simplecble_central_t central, const char* address, const char* service, const char* characteristic, const uint8_t* data, size_t length);
EXPORT bool simplecble_central_write_command(simplecble_central_t central, const char* address, const char* service, const char* characteristic, const uint8_t* data, size_t length);

// --- Peripheral (Player) ---
EXPORT simplecble_peripheral_t simplecble_peripheral_create();
EXPORT void simplecble_peripheral_destroy(simplecble_peripheral_t peripheral);

EXPORT bool simplecble_peripheral_start_advertising(simplecble_peripheral_t peripheral, const char* name, const char* service_uuid);
EXPORT void simplecble_peripheral_stop_advertising(simplecble_peripheral_t peripheral);

typedef void (*simplecble_on_data_received_t)(simplecble_peripheral_t peripheral, const char* service, const char* characteristic, const uint8_t* data, size_t length);
EXPORT void simplecble_peripheral_set_on_data_received(simplecble_peripheral_t peripheral, simplecble_on_data_received_t callback);

// --- Event Callbacks ---
typedef void (*simplecble_on_connection_event_t)(const char* address, bool connected);
EXPORT void simplecble_set_on_connection_event(simplecble_on_connection_event_t callback);

#ifdef __cplusplus
}
#endif

#endif // SIMPLECBLE_H
