# Device Catalog

Complete specifications for all supported devices.

## Athom Smart Plug V3 (PG01V3-EU16A)

### Overview
Compact EU smart plug with power monitoring based on ESP32-C3. Available pre-flashed with ESPHome.

### Hardware Specifications

**Chip:** ESP32-C3 (Single-core RISC-V 160MHz)
**Flash:** 4MB
**Power Monitoring:** CSE7766 (UART-based)
**Buttons:** 1
**Relays:** 1 (single outlet)
**LEDs:** 1 (blue status LED)
**Max Load:** 16A (EU) / 3680W
**Voltage:** 230V AC (EU)

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO5 | Controls outlet |
| Button | GPIO3 | INPUT_PULLUP, inverted |
| Status LED | GPIO6 | Inverted (active low) |
| CSE7766 RX | GPIO20 | UART for power monitoring |

### Features

- ✅ **Power Monitoring** - Voltage, current, watts, energy (kWh), power factor, apparent power
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ✅ **Physical Button** - Manual control with 4-second long-press for restart
- ✅ **Status LED** - Visual feedback for device state
- ✅ **Restore Mode** - Configurable power-on behavior
- ✅ **Compact Size** - Standard EU plug form factor
- ✅ **Pre-flashed** - Available with ESPHome pre-installed from manufacturer
- ✅ **Web Server** - Built-in web interface for monitoring
- ⚠️ **No BLE** - ESP32-C3 configuration doesn't enable Bluetooth

### Usage Example

```yaml
substitutions:
  device_name: heater-plug
  friendly_name: "Office Heater"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  athom:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/diagnostics.yaml
      - devices/athom/pg01v3-eu.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Power Monitoring

The CSE7766 chip provides accurate power monitoring via UART. The configuration includes automatic zero-threshold filtering to prevent phantom readings:

- **Current:** Readings below 60mA are set to 0
- **Power:** Readings below 1W are set to 0
- **Additional metrics:** Power factor and apparent power for advanced monitoring

These thresholds eliminate noise when the outlet is off.

### Known Issues

- ⚠️ **Regional Variants** - This config is for EU (16A) version; US and AU versions exist with different specs
- ⚠️ **UART Logging** - Serial logging may be limited since UART is used for power monitoring

### Flashing Instructions

**Pre-flashed Option:**
- Athom sells these devices pre-flashed with ESPHome
- Simply adopt them in your ESPHome dashboard
- No disassembly or serial connection required

**Initial Flash (Serial Required) - If not pre-flashed:**

1. Open the device case (remove screws)
2. Locate the serial pads or header
3. Connect USB-to-TTL adapter:
   - 3V3 → 3.3V
   - RX → TX
   - TX → RX
   - GND → GND
4. Hold GPIO9 to GND while powering on (enters boot mode)
5. Flash with esphome: `esphome run athom-plug.yaml`

**Subsequent Updates:**
- Over-the-air (OTA) via WiFi
- No disassembly required

### Purchase Links

- [Athom Official Store](https://www.athom.tech/blank-1/esp32-c3-eu-plug-for-esphome) (pre-flashed available)
- [AliExpress](https://www.aliexpress.com/w/wholesale-athom-smart-plug.html) (direct from manufacturer)

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Home Assistant Integration:** Excellent, all entities auto-discovered
- **Reliability:** Very stable, popular in the community
- **Variants:** V2 exists (older ESP8266 version), V3 is ESP32-C3
- **Regional Versions:** EU (16A), US (15A), AU (10A) variants available

### Photos

_TODO: Add device photos, GPIO pinout diagram, opened case_

---

## Wyze Outdoor Plug

### Overview
Dual-outlet outdoor smart plug with power monitoring and BLE support.

### Hardware Specifications

**Chip:** ESP32 (Dual-core Xtensa 240MHz)
**Flash:** 4MB
**Power Monitoring:** HLW8012 (BL0937 variant)
**Buttons:** 2 (one per outlet)
**Relays:** 2 (independent outlets)
**LEDs:** 2 (relay status) + 1 (device status)
**Light Sensor:** Yes (ADC-based)

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay 1 | GPIO15 | Strapping pin |
| Relay 2 | GPIO32 | |
| Button 1 | GPIO18 | INPUT_PULLDOWN, inverted |
| Button 2 | GPIO17 | INPUT_PULLDOWN, inverted |
| LED 1 | GPIO19 | Inverted (active low) |
| LED 2 | GPIO16 | Inverted (active low) |
| Status LED | GPIO5 | Strapping pin, inverted |
| Light Sensor | GPIO34 | ADC input |
| HLW8012 SEL | GPIO25 | Inverted |
| HLW8012 CF | GPIO27 | Pulse counter |
| HLW8012 CF1 | GPIO26 | Pulse counter |

### Features

- ✅ **Power Monitoring** - Voltage, current, watts, energy (kWh)
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ✅ **BLE Proxy** - Bluetooth device passthrough
- ✅ **Dual Independent Outlets** - Control each outlet separately
- ✅ **Physical Buttons** - Manual control with long-press detection
- ✅ **Daylight Sensor** - Automatic light-based automation
- ✅ **Restore Mode** - Configurable power-on behavior
- ⚠️ **No Web Server** - Disabled due to memory constraints with BLE + WiFi

### Usage Example

```yaml
substitutions:
  device_name: patio-plug
  friendly_name: "Patio Lights"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  wyze:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/esp32-ble.yaml
      - common/diagnostics.yaml
      - devices/wyze/outdoor-plug.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Power Monitoring Calibration

Default calibration values work for most units:

```yaml
substitutions:
  current_res: "0.001"    # Current resistor
  voltage_div: "770"      # Voltage divider
```

**If your readings are inaccurate:**

1. **Measure actual power** with a known device (e.g., 60W lamp)
2. **Compare to ESPHome reading**
3. **Calculate correction:**
   - If reading 134W for actual 58W: `134 -> 58` in calibrate_linear
4. **Update the hardware config** and test again

### Known Issues

- ⚠️ **Strapping Pins** - GPIO15 and GPIO5 show warnings but work fine after boot
- ⚠️ **Memory Constraints** - BLE + WiFi + web_server can cause crashes, web server disabled by default
- ⚠️ **Legacy PCNT Driver** - Warning from ESP-IDF, will be fixed in future ESPHome release

### Flashing Instructions

**Initial Flash (Serial Required):**

1. Open the device case (4 screws on back)
2. Connect USB-to-TTL adapter:
   - TX → RX (GPIO3)
   - RX → TX (GPIO1)
   - GND → GND
   - 3.3V → 3.3V (optional if powered)
3. Hold GPIO0 to GND while powering on (boot mode)
4. Flash with esphome: `esphome run wyze-plug.yaml`

**Subsequent Updates:**

- Over-the-air (OTA) via WiFi
- No disassembly required

### Purchase Links

- [Amazon](https://www.amazon.com/s?k=wyze+outdoor+plug) (non-affiliate)
- [Wyze Official](https://www.wyze.com/) (check compatibility - newer models may differ)

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Home Assistant Integration:** Excellent, all entities auto-discovered
- **Reliability:** Very stable with proper configuration
- **Weather Resistance:** IP64 rated outdoor enclosure

### Photos

_TODO: Add device photos, GPIO pinout diagram, opened case_

---

## Sonoff S31

### Overview
Compact indoor smart plug with power monitoring and energy tracking.

### Hardware Specifications

**Chip:** ESP8266 (80MHz)
**Flash:** 1MB
**Power Monitoring:** CSE7766 (UART-based)
**Buttons:** 1
**Relays:** 1 (single outlet)
**LEDs:** 1 (blue status LED)
**Max Load:** 15A

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO12 | Controls outlet |
| Button | GPIO0 | INPUT_PULLUP, inverted |
| LED | GPIO13 | Inverted (active low) |
| CSE7766 RX | GPIO3 (RX) | UART for power monitoring |
| CSE7766 TX | GPIO1 (TX) | UART for power monitoring |

### Features

- ✅ **Power Monitoring** - Voltage, current, watts, energy (kWh)
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ✅ **Physical Button** - Manual control with long-press detection
- ✅ **Status LED** - Visual feedback for device state
- ✅ **Restore Mode** - Configurable power-on behavior
- ✅ **Compact Size** - Fits behind furniture easily
- ⚠️ **No BLE** - ESP8266 doesn't support Bluetooth

### Usage Example

```yaml
substitutions:
  device_name: coffee-maker
  friendly_name: "Coffee Maker"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  sonoff:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp8266-platform.yaml
      - common/diagnostics.yaml
      - devices/sonoff/s31.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Power Monitoring

The CSE7766 chip provides accurate power monitoring via UART. The configuration includes automatic zero-threshold filtering to prevent phantom readings:

- **Current:** Readings below 60mA are set to 0
- **Power:** Readings below 1W are set to 0

These thresholds eliminate noise when the outlet is off.

### Known Issues

- ⚠️ **UART Logging** - Serial logging is limited since RX/TX are used for power monitoring
- ⚠️ **1MB Flash** - Limited space for complex configurations; web_server works but increases boot time

### Flashing Instructions

**Initial Flash (Serial Required):**

**Method 1: With Header Pins (Recommended)**
1. Open the device case (no screws, plastic clips)
2. Locate the 4-pin header (usually unpopulated)
3. Connect USB-to-TTL adapter:
   - 3V3 → 3.3V
   - RX → TX
   - TX → RX
   - GND → GND
4. Hold the button while connecting power (enters flash mode)
5. Flash with esphome: `esphome run sonoff-s31.yaml`

**Method 2: Tasmota Convert (No Disassembly)**
- Older firmware versions can use [Tasmota-Convert](https://github.com/ct-Open-Source/tasmota-convert) OTA method
- Newer firmware requires serial flashing

**Subsequent Updates:**
- Over-the-air (OTA) via WiFi
- No disassembly required

### Purchase Links

- [Amazon](https://www.amazon.com/s?k=sonoff+s31) (non-affiliate)
- [Sonoff Official](https://sonoff.tech/) (check for latest hardware revision)
- [AliExpress](https://www.aliexpress.com/w/wholesale-sonoff-s31.html) (direct from manufacturer)

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Home Assistant Integration:** Excellent, all entities auto-discovered
- **Reliability:** Very stable, widely used in the community
- **Variants:** S31 Lite exists (no power monitoring, cheaper)

### Photos

_TODO: Add device photos, GPIO pinout diagram, opened case_

---

## Adding More Devices

Want to document a new device? See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Each device entry should include:
- Complete specifications
- GPIO pinout table
- Feature list
- Usage example
- Calibration notes
- Known issues
- Flashing instructions
