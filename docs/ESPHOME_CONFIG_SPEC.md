# ESPHome Configuration Functional Specification

A pattern guide for creating modular, maintainable, and modern ESPHome configurations.

---

## 1. Core Principles

### 1.1 DRY (Don't Repeat Yourself)
- Extract ALL reusable configuration into shared packages
- Device files contain ONLY hardware-specific GPIO mappings
- Use substitutions for values that vary (calibration, names, pins)

### 1.2 Working > Features
- Simple, reliable configs beat elaborate, fragile ones
- Get core functionality working before adding features
- Every feature must be tested on real hardware

### 1.3 Security by Default
- Never compile WiFi credentials into firmware
- No hardcoded API encryption keys (users add their own)
- No hardcoded OTA passwords in shared configs
- Credentials stored in NVS, provisioned at runtime

---

## 2. Project Structure

```
project/
├── common/                    # Shared packages (reusable across devices)
│   ├── base.yaml             # Universal: WiFi, API, OTA, logging, time
│   ├── esp32-platform.yaml   # ESP32 framework and platform defaults
│   ├── esp8266-platform.yaml # ESP8266 framework and platform defaults
│   └── diagnostics.yaml      # Health monitoring sensors
│
├── devices/                   # Hardware definitions (one per device model)
│   └── <brand>/
│       └── <model>.yaml      # GPIO mappings, sensors, calibration
│
├── firmware/                  # Build configurations (for CI/releases)
│   └── <brand>-<model>.yaml  # Combines packages for firmware builds
│
└── examples/                  # User-facing templates
    └── <brand>-<model>.yaml  # Copy-paste config for end users
```

---

## 3. Package Layer Hierarchy

Packages should be included in this order (later packages can override earlier ones):

| Layer | File | Contents |
|-------|------|----------|
| 1 | `base.yaml` | WiFi, API, OTA, logger, time, mDNS, captive_portal |
| 2 | `*-platform.yaml` | Framework config, platform-specific substitutions |
| 3 | `diagnostics.yaml` | Health sensors, restart/safe_mode buttons |
| 4 | `device.yaml` | Hardware-specific GPIO, sensors, calibration |

---

## 4. Common Package Specifications

### 4.1 base.yaml

```yaml
# Universal services for ALL devices

logger:
  level: INFO
  logs:
    component: ERROR

api:
  reboot_timeout: 15min
  # No encryption - users add in their config if desired

ota:
  - platform: esphome
  # No password - allows easy recovery

safe_mode:

captive_portal:

mdns:
  disabled: false

wifi:
  min_auth_mode: WPA2  # Reject weaker security (ESPHome 2025.11.0+)
  ap:
    ssid: "${friendly_name} Setup"
    password: "esphome123"  # Standard AP password for provisioning

time:
  - platform: homeassistant
    id: homeassistant_time
```

**Key points:**
- No WiFi SSID/password - provisioned via captive portal
- No API encryption - users add their own unique key
- Standard AP password for consistent provisioning experience

### 4.2 Platform Files

**esp32-platform.yaml:**
```yaml
substitutions:
  verify_ssl: "true"  # ESP-IDF has proper TLS

esp32:
  framework:
    type: esp-idf
    version: recommended
```

**esp8266-platform.yaml:**
```yaml
substitutions:
  verify_ssl: "false"  # ESP8266 has limited TLS

esp8266:
  framework:
    version: recommended
  restore_from_flash: true
```

**Key points:**
- Platform files set platform-specific substitution defaults
- Use substitutions for values that differ between platforms
- ESP32 uses ESP-IDF (better TLS, becoming default in 2026)
- ESP8266 uses Arduino (only option)

### 4.3 diagnostics.yaml

```yaml
sensor:
  - platform: wifi_signal
    name: "WiFi Signal"
    update_interval: 60s
    entity_category: diagnostic

  - platform: uptime
    name: "Uptime"
    entity_category: diagnostic

binary_sensor:
  - platform: status
    name: "Status"
    entity_category: diagnostic

text_sensor:
  - platform: wifi_info
    ip_address:
      name: "IP Address"
      entity_category: diagnostic

button:
  - platform: restart
    name: "Restart"
    entity_category: diagnostic

  - platform: safe_mode
    name: "Safe Mode"
    entity_category: diagnostic
```

**Key points:**
- All diagnostic entities use `entity_category: diagnostic`
- Include restart and safe_mode for recovery
- WiFi signal helps debug connectivity issues

---

## 5. Device File Specifications

Device files contain ONLY hardware-specific configuration:

```yaml
# devices/<brand>/<model>.yaml

substitutions:
  firmware_name: "<brand>-<model>"  # For OTA manifest
  # Calibration values as substitutions
  current_res: "0.001"
  voltage_div: "770"

# Board configuration
esp32:
  board: esp32dev

# OR for ESP8266:
esp8266:
  board: esp01_1m

# Provisioning
improv_serial:

# Hardware-specific components
switch:
  - platform: gpio
    pin: GPIO12
    name: "Relay"
    id: relay
    restore_mode: RESTORE_DEFAULT_OFF

binary_sensor:
  - platform: gpio
    pin:
      number: GPIO0
      mode: INPUT_PULLUP
      inverted: true
    name: "Button"
    internal: true
    filters:
      - delayed_on: 10ms
      - delayed_off: 10ms
    on_press:
      - switch.toggle: relay

status_led:
  pin:
    number: GPIO13
    inverted: true
```

**Key points:**
- Set `firmware_name` substitution (used by OTA)
- Include `improv_serial` for USB provisioning
- Use substitutions for calibration values
- Button debouncing: 10ms delayed_on/off
- Buttons marked `internal: true` if they just toggle relays
- `restore_mode: RESTORE_DEFAULT_OFF` for safety

---

## 6. Firmware Build Specifications

Firmware files combine packages for CI builds and enable Dashboard adoption:

```yaml
# firmware/<brand>-<model>.yaml

substitutions:
  device_name: <brand>-<model>
  friendly_name: "<Brand> <Model>"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}
  name_add_mac_suffix: true  # Unique names for multiple devices
  project:
    name: "your-org.your-project"
    version: !env_var FIRMWARE_VERSION dev

# Enable adoption in ESPHome Dashboard
# Dashboard generates unique API encryption key per device during adoption
dashboard_import:
  package_import_url: github://<owner>/<repo>/firmware/<brand>-<model>.yaml@main
  import_full_config: false

packages:
  base: !include ../common/base.yaml
  platform: !include ../common/esp32-platform.yaml
  diagnostics: !include ../common/diagnostics.yaml
  hardware: !include ../devices/<brand>/<model>.yaml

# BLE provisioning (ESP32 only)
esp32_improv:
  authorizer: none  # No button required to authorize
```

**Key points:**
- `name_add_mac_suffix: true` for release builds
- `dashboard_import` enables adoption with auto-generated encryption keys
- `esp32_improv` adds BLE WiFi provisioning (ESP32 only, omit for ESP8266)
- `project` is required for Dashboard discovery
- Include packages in correct order
- Use `!include` for local file references

---

## 7. Example File Specifications

Example files use GitHub URL imports for end users:

```yaml
# examples/<brand>-<model>.yaml

# <Brand> <Model> - Example Configuration
# Copy this and customize for your device
#
# First boot:
# 1. Device creates WiFi AP: "<friendly_name> Setup"
# 2. Connect with password: esphome123
# 3. Open http://192.168.4.1
# 4. Enter your WiFi credentials

substitutions:
  device_name: <brand>-<model>-livingroom  # Change this!
  friendly_name: "Living Room <Model>"     # Change this!

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  base:
    url: https://github.com/<owner>/<repo>
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/diagnostics.yaml
      - devices/<brand>/<model>.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

**Key points:**
- Clear instructions in comments
- Use GitHub URL imports (not `!include`)
- `refresh: 1d` for daily package updates
- User only changes substitutions

---

## 8. Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Directories | lowercase, hyphens | `devices/sonoff/` |
| Files | lowercase, hyphens | `outdoor-plug.yaml` |
| Substitutions | snake_case | `device_name`, `firmware_name` |
| Entity IDs | snake_case | `relay`, `power_sensor` |
| Entity Names | Title Case | `"Power"`, `"Daily Energy"` |

---

## 9. Substitution Standards

### Required Substitutions (set by device file):
```yaml
substitutions:
  firmware_name: "brand-model"  # Must match manifest filename
```

### Required Substitutions (set by firmware/example):
```yaml
substitutions:
  device_name: brand-model-location
  friendly_name: "Location Device Name"
```

### Calibration Substitutions (device-specific):
```yaml
substitutions:
  current_res: "0.001"
  voltage_div: "770"
```

### Platform Substitutions (set by platform file):
```yaml
substitutions:
  verify_ssl: "true"  # or "false" for ESP8266
```

---

## 10. Sensor Best Practices

### Power Monitoring
```yaml
sensor:
  - platform: hlw8012  # or cse7766
    power:
      name: "Power"
      id: power
      filters:
        - calibrate_linear:
            - 0.0 -> 0.0
            - 134.0 -> 58.0  # Measured calibration
        - lambda: if (x < 1) return 0.0; else return x;  # Filter noise

  - platform: total_daily_energy
    name: "Daily Energy"
    power_id: power
    unit_of_measurement: kWh
    filters:
      - multiply: 0.001
```

### Throttling High-Frequency Sensors
```yaml
sensor:
  - platform: cse7766
    current:
      name: "Current"
      filters:
        - throttle_average: 60s  # Average over 60s, report once
```

---

## 11. Button Debouncing

Standard pattern for physical buttons:

```yaml
binary_sensor:
  - platform: gpio
    pin:
      number: GPIO0
      mode: INPUT_PULLUP
      inverted: true
    filters:
      - delayed_on: 10ms
      - delayed_off: 10ms
    on_press:
      - switch.toggle: relay
```

---

## 12. Entity Categories

Use `entity_category` to organize Home Assistant UI:

| Category | Use For |
|----------|---------|
| (none) | Primary controls and sensors (relay, power) |
| `config` | User-adjustable settings |
| `diagnostic` | Health/debug info (WiFi signal, uptime, IP) |

---

## 13. Device Provisioning & Adoption

Devices use the [Improv WiFi](https://www.improv-wifi.com/) standard for first-time setup:

```
1. User flashes firmware via ESPHome Dashboard or web installer
2. improv_serial prompts for WiFi credentials (in browser)
3. Device connects to network
4. ESPHome Dashboard discovers device (via mDNS + project info)
5. User clicks "Adopt" in Dashboard
6. Dashboard generates local config with:
   - Package imports from GitHub repo
   - UNIQUE API encryption key (per device!)
   - Customized device name
```

### Provisioning Components

| Component | Purpose | Platform |
|-----------|---------|----------|
| `improv_serial` | USB/Serial WiFi provisioning | All |
| `esp32_improv` | BLE WiFi provisioning | ESP32 only |
| `captive_portal` | Fallback AP with web config | All |
| `dashboard_import` | Enables Dashboard adoption | All |

### Security Model

- **No credentials compiled into firmware** - WiFi provisioned via Improv
- **No shared API encryption keys** - Dashboard generates unique key per device
- **Credentials stored in NVS** - Persist across OTA updates

---

## 14. Security Checklist

- [ ] No WiFi credentials compiled in
- [ ] No hardcoded API encryption key
- [ ] No hardcoded OTA password
- [ ] `min_auth_mode: WPA2` in wifi config
- [ ] `improv_serial` for USB provisioning
- [ ] `esp32_improv` for BLE provisioning (ESP32)
- [ ] `dashboard_import` for adoption flow
- [ ] `captive_portal` for fallback WiFi setup
- [ ] `safe_mode` enabled for recovery

---

## 15. Anti-Patterns to Avoid

| Don't | Do Instead |
|-------|------------|
| Compile WiFi credentials | Use Improv + captive_portal |
| Share API encryption keys | Use dashboard_import (keys generated per-device) |
| Duplicate code between devices | Extract to common/ |
| Hardcode calibration values | Use substitutions |
| Skip `entity_category` | Always categorize diagnostics |
| Use Arduino on ESP32 | Use ESP-IDF (better TLS) |
| Complex configs before simple works | Get basics working first |

---

## 15. Validation Checklist

Before considering a config complete:

- [ ] Compiles without errors
- [ ] Flashes successfully
- [ ] WiFi provisioning works (captive portal)
- [ ] Appears in Home Assistant
- [ ] Primary function works (relay, sensor, etc.)
- [ ] OTA update works
- [ ] Restart button works
- [ ] Safe mode accessible

---

## Summary

The goal is configs that are:
- **Modular**: Shared code in packages, device-specific in device files
- **Maintainable**: Clear structure, consistent naming
- **Secure**: No compiled credentials, proper provisioning
- **Modern**: ESP-IDF, current best practices
- **Testable**: Works on real hardware, not just compiles
