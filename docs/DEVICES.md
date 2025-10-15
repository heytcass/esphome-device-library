# Device Catalog

Complete specifications for all supported devices.

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
