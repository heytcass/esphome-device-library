# Contributing to ESPHome Device Library

Thank you for your interest in contributing! This guide walks you through adding a new device to the library.

## Before You Start

**Requirements:**
- The device must be ESP8266 or ESP32 based
- You must have physical access to the device for testing
- HTTP OTA is mandatory - every device must support automatic updates

**Read first:**
- [PROJECT.md](PROJECT.md) - Understand the architecture and principles
- [ESPHome Documentation](https://esphome.io/) - Familiarize yourself with ESPHome

---

## Adding a New Device

### Step 1: Create the Hardware Definition

Create `devices/<brand>/<model>.yaml` with hardware-specific configuration:

```yaml
# devices/acme/smart-plug.yaml

substitutions:
  firmware_name: "acme-smart-plug"  # Must match manifest filename
  # Add calibration values as substitutions for easy tuning
  current_res: "0.001"
  voltage_div: "770"

# Board configuration
esp32:
  board: esp32dev

# GPIO mappings - the hardware-specific part
switch:
  - platform: gpio
    pin: GPIO12
    name: "Relay"
    id: relay
    restore_mode: RESTORE_DEFAULT_OFF

binary_sensor:
  - platform: gpio
    pin:
      number: GPIO4
      mode: INPUT_PULLUP
      inverted: true
    name: "Button"
    on_press:
      - switch.toggle: relay

status_led:
  pin:
    number: GPIO13
    inverted: true
```

**Key requirements:**
- Set `firmware_name` substitution (used by HTTP OTA)
- Use substitutions for calibration values
- Only include hardware-specific GPIO mappings
- Do NOT include `improv_serial:` here (that goes in factory configs only)

### Step 2: Create Firmware Build Configs (Base + Factory)

Create TWO configs: a base config for adopted devices, and a factory config for pre-built firmware.

**Base config** - `firmware/<brand>-<model>.yaml`:
```yaml
# firmware/acme-smart-plug.yaml

substitutions:
  device_name: acme-smart-plug
  friendly_name: "ACME Smart Plug"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}
  name_add_mac_suffix: true
  project:
    name: "heytcass.esphome-device-library"
    version: !env_var FIRMWARE_VERSION dev

packages:
  base: !include ../common/base.yaml
  platform: !include ../common/esp32-platform.yaml  # or esp8266-platform.yaml
  diagnostics: !include ../common/diagnostics.yaml
  hardware: !include ../devices/acme/smart-plug.yaml
```

**Factory config** - `firmware/<brand>-<model>.factory.yaml`:
```yaml
# firmware/acme-smart-plug.factory.yaml
# Extends base with HTTP OTA, Improv, and dashboard adoption

packages:
  device: !include acme-smart-plug.yaml
  http_ota: !include ../common/http-ota.yaml

dashboard_import:
  package_import_url: github://heytcass/esphome-device-library/firmware/acme-smart-plug.yaml@main
  import_full_config: false

improv_serial:

esp32_improv:
  authorizer: none
```

**Key requirements:**
- Base config: NO `http-ota.yaml` (for adopted devices)
- Factory config: Extends base + adds HTTP OTA, Improv, dashboard_import
- Use `name_add_mac_suffix: true` for release builds
- Set project version to `!env_var FIRMWARE_VERSION dev`

### Step 3: Create the User Example

Create `examples/<brand>-<model>.yaml` for users to copy:

```yaml
# examples/acme-smart-plug.yaml
# ACME Smart Plug - Example Configuration
# Copy this file and customize for your device
#
# First boot:
# 1. Device creates WiFi AP: "<friendly_name> Setup"
# 2. Connect to AP with password: esphome123
# 3. Open http://192.168.4.1 in browser
# 4. Enter your WiFi credentials
# 5. Device reboots and connects to your network

substitutions:
  device_name: acme-smart-plug-kitchen    # Change this! Must be unique
  friendly_name: "Kitchen Smart Plug"      # Change this! Shows in Home Assistant

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  base:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/http-ota.yaml
      - common/esp32-platform.yaml  # or esp8266-platform.yaml
      - common/diagnostics.yaml
      - devices/acme/smart-plug.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${device_name} Fallback"
```

### Step 4: Update CI Workflows

Add your device to `.github/workflows/validate.yaml`:

```yaml
strategy:
  matrix:
    config:
      - examples/wyze-outdoor-plug.yaml
      - examples/acme-smart-plug.yaml  # Add your device
```

Add your device to `.github/workflows/build-firmware.yaml`:

```yaml
strategy:
  matrix:
    config:
      - firmware/wyze-outdoor-plug.yaml
      - firmware/acme-smart-plug.yaml  # Add your device
```

### Step 5: Test on Real Hardware

**Required testing:**
1. Flash firmware via USB
2. Verify WiFi provisioning works (captive portal)
3. Confirm device appears in Home Assistant
4. Create a release and verify OTA update works
5. Confirm all sensors/switches function correctly

---

## WiFi Provisioning Flow

Devices use captive portal for WiFi setup (no credentials compiled in):

1. **First boot**: Device creates AP named `<device_name> Fallback`
2. **Connect**: Join the AP with password `esphome123`
3. **Configure**: Browser opens automatically (or go to http://192.168.4.1)
4. **Enter credentials**: Submit your WiFi SSID and password
5. **Reboot**: Device connects to your network

Credentials are stored in NVS flash and persist across OTA updates.

**Alternative methods:**
- **Improv Serial**: Use ESPHome web installer via USB
- **Improv BLE** (ESP32 only): Use ESPHome mobile app

---

## Code Standards

### DRY Principle
- If code could be shared between devices, it belongs in `common/`
- Device files contain ONLY hardware-specific GPIO mappings
- Use substitutions for calibration values

### Naming Conventions
- Directories: lowercase, hyphens (`devices/acme/`)
- Files: lowercase, hyphens (`smart-plug.yaml`)
- Substitutions: snake_case (`device_name`, `firmware_name`)

### Required Components
Every device MUST include:
- `common/base.yaml` - WiFi, API, OTA, logging
- `common/http-ota.yaml` - Automatic updates (non-negotiable)
- `common/diagnostics.yaml` - Health monitoring
- Platform file (`esp32-platform.yaml` or `esp8266-platform.yaml`)

---

## Pull Request Checklist

Before submitting:

- [ ] Device file in `devices/<brand>/<model>.yaml`
- [ ] Firmware config in `firmware/<brand>-<model>.yaml`
- [ ] Example in `examples/<brand>-<model>.yaml`
- [ ] Added to `validate.yaml` workflow matrix
- [ ] Added to `build-firmware.yaml` workflow matrix
- [ ] Tested on real hardware
- [ ] HTTP OTA update verified working
- [ ] All sensors/switches functioning
- [ ] Follows DRY principle (no duplicated code)
- [ ] Uses substitutions for calibration values

---

## Getting Help

- Open an issue for questions
- Check existing device configs for examples
- Review [PROJECT.md](PROJECT.md) for architecture decisions
