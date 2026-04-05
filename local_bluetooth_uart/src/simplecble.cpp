#include "simplecble.h"
#include <simpleble/SimpleBLE.h>
#include <map>
#include <string>
#include <vector>
#include <mutex>

#ifdef __ANDROID__
#include <jni.h>
static JavaVM* g_jvm = nullptr;
extern "C" jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    g_jvm = vm;
    return JNI_VERSION_1_6;
}
// Stub for modern NDKs that don't provide libnativehelper
extern "C" jint JNI_GetCreatedJavaVMs(JavaVM** vmBuf, jsize bufLen, jsize* nVMs) {
    if (bufLen > 0 && g_jvm != nullptr) {
        vmBuf[0] = g_jvm;
        if (nVMs) *nVMs = 1;
        return JNI_OK;
    }
    if (nVMs) *nVMs = 0;
    return JNI_ERR;
}
#endif

// Mocking some parts since SimpleBLE doesn't have a direct C wrapper in its default distro.
// This implements the requested symbols using SimpleBLE's C++ API.

using namespace SimpleBLE;

struct SimpleCbleCentral {
    Adapter adapter;
    std::vector<Peripheral> peripherals;
    simplecble_on_peripheral_found_t on_found = nullptr;
    std::mutex mtx;
};

struct SimpleCblePeripheral {
    // Note: SimpleBLE's Peripheral role (Server) is handled via Peripheral class in newer versions
    // but typically you need a different API for advertising.
    // For the sake of the tracer bullet, we assume a SimpleBLE server implementation exists.
    std::string name;
    std::string service_uuid;
    simplecble_on_data_received_t on_received = nullptr;
};

static simplecble_on_connection_event_t global_connection_event_cb = nullptr;

extern "C" {

simplecble_central_t simplecble_central_create() {
    auto adapters = Adapter::get_adapters();
    if (adapters.empty()) return nullptr;
    
    auto* central = new SimpleCbleCentral();
    central->adapter = adapters[0];
    return (simplecble_central_t)central;
}

void simplecble_central_destroy(simplecble_central_t central) {
    delete (SimpleCbleCentral*)central;
}

bool simplecble_central_start_scan(simplecble_central_t central, const char* service_uuid) {
    auto* c = (SimpleCbleCentral*)central;
    c->adapter.set_callback_on_scan_found([c, service_uuid](Peripheral p) {
        if (c->on_found) {
            c->on_found(c, p.identifier().c_str(), p.address().c_str());
        }
    });
    c->adapter.scan_start();
    return true;
}

void simplecble_central_stop_scan(simplecble_central_t central) {
    ((SimpleCbleCentral*)central)->adapter.scan_stop();
}

void simplecble_central_set_on_peripheral_found(simplecble_central_t central, simplecble_on_peripheral_found_t callback) {
    ((SimpleCbleCentral*)central)->on_found = callback;
}

bool simplecble_central_connect(simplecble_central_t central, const char* address) {
    // In a real implementation, we'd find the peripheral from the scan results
    return true; 
}

void simplecble_central_disconnect(simplecble_central_t central, const char* address) {
    // Disconnect logic
}

bool simplecble_central_write_command(simplecble_central_t central, const char* address, const char* service, const char* characteristic, const uint8_t* data, size_t length) {
    // Map address to peripheral and call p.write_command(service, characteristic, ByteArray((char*)data, length))
    return true;
}

// Peripheral role
simplecble_peripheral_t simplecble_peripheral_create() {
    return (simplecble_peripheral_t)new SimpleCblePeripheral();
}

void simplecble_peripheral_destroy(simplecble_peripheral_t peripheral) {
    delete (SimpleCblePeripheral*)peripheral;
}

bool simplecble_peripheral_start_advertising(simplecble_peripheral_t peripheral, const char* name, const char* service_uuid) {
    auto* p = (SimpleCblePeripheral*)peripheral;
    p->name = name;
    p->service_uuid = service_uuid;
    // Advertising logic using SimpleBLE (if supported) or OS native
    return true;
}

void simplecble_peripheral_stop_advertising(simplecble_peripheral_t peripheral) {
    // Stop advertising
}

void simplecble_set_on_connection_event(simplecble_on_connection_event_t callback) {
    global_connection_event_cb = callback;
}

}
