# Device Catalog

Complete specifications for all supported devices.

## AirGradient ONE - Board v9

### Overview
Comprehensive air quality monitor measuring PM2.5, CO2, VOC, NOx, temperature, and humidity. Features an OLED display and WS2812 LED strip for visual feedback.

### Hardware Specifications

**Chip:** ESP32-C3 (Single-core RISC-V 160MHz)
**Flash:** 4MB
**Sensors:**
- PMS5003 (Particulate Matter via UART)
- SenseAir S8 (CO2 via UART)
- SHT40 (Temperature/Humidity via I2C)
- SGP41 (VOC/NOx via I2C)

**Display:** SH1106 128x64 OLED (I2C)
**LED:** WS2812 RGB strip (11 LEDs)
**Connectivity:** WiFi 2.4GHz

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| SenseAir S8 RX | GPIO0 | UART for CO2 sensor |
| SenseAir S8 TX | GPIO1 | UART for CO2 sensor |
| Watchdog | GPIO2 | Device heartbeat |
| I2C SCL | GPIO6 | SHT40, SGP41, OLED |
| I2C SDA | GPIO7 | SHT40, SGP41, OLED |
| LED Strip | GPIO10 | WS2812 (11 LEDs) |
| PMS5003 RX | GPIO20 | UART for PM sensor |
| PMS5003 TX | GPIO21 | UART for PM sensor |

### Features

- ✅ **PM2.5 Monitoring** - Real-time particulate matter with automatic AQI calculation
- ✅ **CO2 Monitoring** - SenseAir S8 NDIR sensor (400-10000 ppm)
- ✅ **VOC & NOx** - SGP41 sensor with temperature/humidity compensation
- ✅ **Temperature & Humidity** - SHT40 high-accuracy sensor
- ✅ **OLED Display** - Auto-rotating pages showing all measurements
- ✅ **LED Indicators** - Color-coded CO2 levels (green→yellow→orange→red→purple→dark red)
- ✅ **Calibration Controls** - Buttons for CO2 sensor calibration
- ✅ **Temperature Units** - Toggle between °F and °C
- ✅ **Web Server** - Built-in web interface for monitoring
- ✅ **Watchdog** - Hardware watchdog for reliability
- ⚠️ **No Serial Logging** - Both UARTs used by sensors

### Usage Example

```yaml
substitutions:
  device_name: airgradient-office
  friendly_name: "Office Air Quality"
  led_strip_brightness: "25%"  # Customize brightness

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  airgradient:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/diagnostics.yaml
      - devices/airgradient/one-v9.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Sensor Details

**PM2.5 (Particulate Matter):**
- Readings in µg/m³
- Automatic AQI (Air Quality Index) calculation
- Update interval: 2 minutes
- Also reports PM1.0, PM10.0, PM0.3

**CO2 (Carbon Dioxide):**
- Range: 400-10000 ppm
- Clamped minimum at 400 ppm (atmospheric baseline)
- Automatic background calibration available
- LED strip shows color-coded levels:
  - Green: <800 ppm (excellent)
  - Yellow: 800-1000 ppm (good)
  - Orange: 1000-1500 ppm (moderate)
  - Red: 1500-2000 ppm (poor)
  - Purple: 2000-3000 ppm (very poor)
  - Dark Red: >3000 ppm (hazardous)

**VOC & NOx:**
- Index values (1-500)
- Temperature and humidity compensated
- Requires 12-hour conditioning period for accuracy

**Temperature & Humidity:**
- High accuracy (±0.2°C, ±2% RH)
- Display toggle for °F/°C
- Used for VOC/NOx compensation

### Display Pages

The OLED cycles through pages every 5 seconds:

**Page 1:**
- CO2 (ppm)
- PM2.5 (µg/m³)
- Temperature (°F or °C)
- Humidity (%)

**Page 2:**
- CO2 (ppm)
- PM2.5 (µg/m³)
- VOC Index
- NOx Index

**Boot Page** (first 5 seconds):
- Device MAC address
- Device name

### CO2 Calibration

The SenseAir S8 sensor supports calibration:

**Automatic Baseline Calibration (ABC):**
- Enable: Use "Enable S8 Auto Calibration" button in Home Assistant
- Assumes sensor sees 400 ppm regularly (fresh air)
- Best for residential use

**Manual Calibration:**
1. Place sensor in fresh air (outdoors) for 20+ minutes
2. Press "SenseAir S8 Calibration" button
3. Wait 70 seconds for calibration to complete
4. Best for commercial/lab use

### Known Issues

- ⚠️ **No Serial Logging** - Both ESP32-C3 UARTs are used, serial debugging unavailable
- ⚠️ **SGP41 Conditioning** - VOC/NOx readings stabilize after 12 hours of operation
- ⚠️ **Multiple Devices** - Sensor names may conflict; customize friendly_name for each unit

### Flashing Instructions

**Initial Flash (Serial Required):**

1. Connect USB-C cable to AirGradient ONE
2. Device appears as USB serial port
3. No disassembly required
4. Flash with esphome: `esphome run airgradient-one.yaml`

**Subsequent Updates:**
- Over-the-air (OTA) via WiFi
- No cable required

### Purchase Links

- [AirGradient Official Store](https://www.airgradient.com/open-airgradient/instructions/overview/) (DIY kits and pre-assembled)
- Open-source hardware with detailed build instructions

### Community Notes

- **Tested ESPHome Versions:** 2023.7.0+ (required)
- **Home Assistant Integration:** Excellent, all sensors auto-discovered
- **Reliability:** Very stable with watchdog enabled
- **Accuracy:** Professional-grade sensors, suitable for air quality research
- **Open Source:** Full schematics and build guide available
- **Assembly:** DIY kit available, or purchase pre-assembled

### Photos

_TODO: Add device photos, GPIO pinout diagram, sensor locations_

---

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

## Sonoff Basic R2

### Overview
Ultra-affordable ESP8266-based smart switch with physical button. One of the most popular beginner-friendly ESPHome devices.

### Hardware Specifications

**Chip:** ESP8266 (80MHz)
**Flash:** 1MB
**Buttons:** 1
**Relays:** 1
**LEDs:** 1 (blue status LED)
**Max Load:** 10A

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO12 | Controls output |
| Button | GPIO0 | INPUT_PULLUP, inverted |
| LED | GPIO13 | Inverted (active low) |

### Features

- ✅ **Simple Switch Control** - Single relay for basic switching
- ✅ **Physical Button** - Manual control with long-press detection
- ✅ **Status LED** - Visual feedback for device state
- ✅ **Compact Size** - Fits in standard electrical boxes
- ✅ **Very Affordable** - Budget-friendly option ($5-10)
- ⚠️ **No Power Monitoring** - Use S31 or POW Elite for power monitoring

### Usage Example

```yaml
substitutions:
  device_name: bedroom-light
  friendly_name: "Bedroom Light"

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
      - devices/sonoff/basic-r2.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Reliability:** Very stable, extremely popular in the community
- **Use Cases:** Lights, fans, simple on/off devices

---

## Shelly 1

### Overview
Compact ESP8266-based in-wall smart switch designed to fit behind existing wall switches. Very popular in EU markets.

### Hardware Specifications

**Chip:** ESP8266 (80MHz)
**Flash:** 1MB
**Relays:** 1 (16A rating)
**Switch Input:** 1
**Size:** 41x36x17mm

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO4 | 16A relay output |
| Switch Input | GPIO5 | Physical wall switch connection |

### Features

- ✅ **In-Wall Installation** - Extremely compact form factor
- ✅ **Physical Switch Support** - Connects to existing wall switches
- ✅ **16A Rating** - Higher current than most competitors
- ✅ **CE Certified** - Meets EU safety standards
- ⚠️ **No Power Monitoring** - Use Plus 1PM for power monitoring

### Usage Example

```yaml
substitutions:
  device_name: hallway-light
  friendly_name: "Hallway Light"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  shelly:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp8266-platform.yaml
      - common/diagnostics.yaml
      - devices/shelly/1.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Installation:** Requires electrical knowledge for in-wall installation
- **Successor:** Shelly Plus 1 (ESP32-based with more features)

---

## Shelly Plus 1

### Overview
Modern ESP32-based in-wall smart switch with Bluetooth support. Successor to the popular Shelly 1.

### Hardware Specifications

**Chip:** ESP32 (Dual-core 240MHz)
**Flash:** 4MB
**Relays:** 1 (16A rating)
**Switch Input:** 1
**Button:** 1
**Connectivity:** WiFi + Bluetooth

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO26 | 16A relay output |
| Switch Input | GPIO4 | Physical wall switch connection |
| Button | GPIO25 | Manual control button |

### Features

- ✅ **ESP32 Power** - Dual-core processor for advanced features
- ✅ **Bluetooth Support** - BLE proxy and provisioning
- ✅ **Physical Switch Support** - Connects to existing wall switches
- ✅ **16A Rating** - High current capacity
- ⚠️ **No Power Monitoring** - Use Plus 1PM for power monitoring

### Usage Example

```yaml
substitutions:
  device_name: bathroom-fan
  friendly_name: "Bathroom Fan"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  shelly:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/esp32-ble.yaml
      - common/diagnostics.yaml
      - devices/shelly/plus-1.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Variants:** Plus 1 Mini (ESP32-C3, even more compact)
- **Installation:** Requires electrical knowledge for in-wall installation

---

## Shelly 2.5

### Overview
Dual-relay ESP8266 switch with power monitoring, extremely popular for roller shutters and blinds control.

### Hardware Specifications

**Chip:** ESP8266 (80MHz)
**Flash:** 1MB
**Power Monitoring:** ADE7953 (I2C, dual-channel)
**Relays:** 2 (independent or linked)
**Switch Inputs:** 2
**Temperature Sensor:** NTC thermistor

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay 1 | GPIO4 | First relay output |
| Relay 2 | GPIO15 | Second relay output |
| Switch Input 1 | GPIO13 | First physical switch |
| Switch Input 2 | GPIO5 | Second physical switch |
| Button | GPIO2 | Mode button |
| LED | GPIO0 | Status indicator |
| I2C SDA | GPIO12 | ADE7953 power monitor |
| I2C SCL | GPIO14 | ADE7953 power monitor |
| ADE7953 IRQ | GPIO16 | CRITICAL for temp management |
| NTC Sensor | A0 | Temperature monitoring |

### Features

- ✅ **Dual Channel Power Monitoring** - Independent monitoring per channel
- ✅ **Roller Shutter Mode** - Perfect for blinds and covers
- ✅ **Temperature Monitoring** - Prevents overheating
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ⚠️ **Runs Hot** - Normal operating temperature ~55°C, IRQ pin critical

### Usage Example

```yaml
substitutions:
  device_name: office-blinds
  friendly_name: "Office Blinds"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  shelly:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp8266-platform.yaml
      - common/diagnostics.yaml
      - devices/shelly/2.5.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Known Issues

- ⚠️ **IRQ Pin Required** - GPIO16 IRQ pin is critical for preventing overheating
- ⚠️ **Temperature** - Runs warm (50-60°C) by design, monitor temp sensor

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Most Popular Use:** Roller shutters, blinds, garage doors
- **Successor:** Shelly Plus 2PM (ESP32-based)

---

## Sonoff 4CH Pro R2

### Overview
Four-channel ESP8266 relay module for multi-zone control (irrigation, lighting zones, HVAC).

### Hardware Specifications

**Chip:** ESP8266 (80MHz)
**Flash:** 1MB
**Relays:** 4 (independent, 10A each)
**Buttons:** 4 (one per channel)
**LEDs:** 4 (one per relay)

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay 1 | GPIO12 | First channel |
| Relay 2 | GPIO5 | Second channel |
| Relay 3 | GPIO4 | Third channel |
| Relay 4 | GPIO15 | Fourth channel |
| Button 1 | GPIO0 | First button |
| Button 2 | GPIO9 | Second button |
| Button 3 | GPIO10 | Third button |
| Button 4 | GPIO14 | Fourth button |

### Features

- ✅ **4 Independent Relays** - Control 4 separate zones
- ✅ **Physical Buttons** - Manual control for each channel
- ✅ **Status LEDs** - Visual feedback per channel
- ✅ **10A Per Channel** - Suitable for most appliances
- ⚠️ **Requires Disassembly** - Must open case for flashing

### Usage Example

```yaml
substitutions:
  device_name: garden-irrigation
  friendly_name: "Garden Irrigation"

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
      - devices/sonoff/4ch-pro-r2.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Common Use Cases

- **Irrigation Systems** - 4 independent zones
- **Lighting Control** - Multi-room control
- **HVAC Zones** - Multiple heating/cooling zones

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Variants:** 4CH (non-Pro) exists with fewer features

---

## AI-Thinker ESP32-CAM

### Overview
Ultra-affordable ESP32 camera module with OV2640 2MP camera. One of the most popular DIY camera options.

### Hardware Specifications

**Chip:** ESP32 (Dual-core 240MHz)
**Flash:** 4MB
**Camera:** OV2640 (2MP, 1600x1200 max)
**MicroSD:** Card slot for storage
**Flash LED:** White LED on GPIO4
**Status LED:** Red LED on GPIO33
**Price:** $5-10

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Camera XCLK | GPIO0 | 20MHz external clock |
| I2C SDA | GPIO26 | Camera control |
| I2C SCL | GPIO27 | Camera control |
| Flash LED | GPIO4 | White LED (PWM) |
| Status LED | GPIO33 | Red status LED |

**Available GPIOs:** 1, 3, 12, 13, 14, 15
**WARNING:** DO NOT USE GPIO16 - connected to PSRAM!

### Features

- ✅ **2MP Camera** - OV2640 sensor, 1600x1200 resolution
- ✅ **Video Streaming** - Real-time MJPEG stream
- ✅ **Flash LED** - Controllable white LED
- ✅ **MicroSD Slot** - Local storage option
- ✅ **Extremely Affordable** - $5-10 per unit
- ⚠️ **Limited GPIOs** - Most pins used by camera

### Usage Example

```yaml
substitutions:
  device_name: front-door-camera
  friendly_name: "Front Door Camera"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  esp32cam:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/diagnostics.yaml
      - devices/ai-thinker/esp32-cam.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Known Issues

- ⚠️ **GPIO16 PSRAM** - Using GPIO16 will trigger watchdog resets
- ⚠️ **Power Requirements** - Needs stable 5V supply
- ⚠️ **No Enclosure** - Sold as bare board, requires housing

### Community Notes

- **Tested ESPHome Versions:** 2024.6.0+
- **Use Cases:** Doorbells, security cameras, wildlife monitoring

---

## Sonoff POW Elite (POWR316D)

### Overview
ESP32-based power monitoring switch with built-in LCD display. High-end successor to POW R2.

### Hardware Specifications

**Chip:** ESP32 (Dual-core 240MHz)
**Flash:** 4MB
**Power Monitoring:** CSE7766 (UART)
**Display:** TM1621 LCD (6-digit)
**Max Load:** 16A (POWR316D) or 20A (POWR320D)
**Button:** 1

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO27 | Power control |
| Button | GPIO0 | Manual control |
| CSE7766 RX | GPIO16 | UART power monitoring |

### Features

- ✅ **Advanced Power Monitoring** - Voltage, current, power, energy, power factor
- ✅ **Built-in LCD Display** - Shows real-time power metrics
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ✅ **ESP32 Power** - Bluetooth and advanced features
- ✅ **16A/20A Options** - Two models available
- ⚠️ **LCD Not Supported** - TM1621 display needs custom component

### Usage Example

```yaml
substitutions:
  device_name: washing-machine
  friendly_name: "Washing Machine"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  sonoff:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/diagnostics.yaml
      - devices/sonoff/pow-elite.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Use Cases:** Appliance monitoring, energy tracking
- **Alternative:** S31 for simpler/cheaper option

---

## Athom Smart Plug V2 (US 16A)

### Overview
ESP8285-based US smart plug with power monitoring. Available pre-flashed with ESPHome.

### Hardware Specifications

**Chip:** ESP8285 (2MB flash)
**Flash:** 2MB
**Power Monitoring:** CSE7766 (UART)
**Buttons:** 1
**Relays:** 1
**LEDs:** 1 (blue status LED)
**Max Load:** 16A / 1920W (US 120V)

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO12 | Controls outlet |
| Button | GPIO5 | INPUT_PULLUP, inverted |
| LED | GPIO13 | Inverted (active low) |
| CSE7766 RX | GPIO3 (RX) | UART power monitoring |

### Features

- ✅ **Power Monitoring** - Voltage, current, watts, energy, power factor
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ✅ **Pre-flashed Option** - Available with ESPHome from manufacturer
- ✅ **2MB Flash** - More space than typical 1MB devices
- ✅ **"Made for ESPHome"** - Certified by ESPHome project

### Usage Example

```yaml
substitutions:
  device_name: desk-lamp
  friendly_name: "Office Desk Lamp"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  athom:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp8266-platform.yaml
      - common/diagnostics.yaml
      - devices/athom/pg01v2-us.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Purchase:** Available pre-flashed from [Athom](https://www.athom.tech/)
- **Variants:** US (16A), EU (16A), AU (10A) versions available

---

## Sonoff Mini R4

### Overview
Ultra-compact ESP32-based in-wall smart switch. Smallest WiFi switch on the market (40x30mm).

### Hardware Specifications

**Chip:** ESP32 (Dual-core 240MHz)
**Flash:** 4MB
**Relays:** 1 (10A rating)
**Size:** 40x30mm
**Button:** 1
**External Switch Input:** 1

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO26 | Output control |
| Button | GPIO0 | Manual control button |
| External Switch | GPIO4 | Physical wall switch input |
| LED | GPIO19 | Status indicator |

### Features

- ✅ **Ultra-Compact** - Smallest WiFi switch (40x30mm)
- ✅ **ESP32 Power** - Bluetooth and advanced features
- ✅ **Physical Switch Support** - Connects to wall switches
- ✅ **10A Rating** - Suitable for most lighting
- ⚠️ **No Power Monitoring** - Use POW Elite for monitoring

### Usage Example

```yaml
substitutions:
  device_name: closet-light
  friendly_name: "Closet Light"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  sonoff:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/esp32-ble.yaml
      - common/diagnostics.yaml
      - devices/sonoff/mini-r4.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Use Cases:** Tight spaces, minimal installations
- **Successor to:** Sonoff Mini (ESP8266)

---

## Shelly Plus 1PM

### Overview
ESP32-based in-wall smart switch with power monitoring. Combines relay control with energy tracking.

### Hardware Specifications

**Chip:** ESP32 (Dual-core 240MHz)
**Flash:** 4MB
**Power Monitoring:** BL0942 (UART)
**Relays:** 1 (16A rating)
**Switch Input:** 1
**Button:** 1
**Temperature Sensor:** NTC thermistor

### GPIO Pinout

| Component | GPIO | Notes |
|-----------|------|-------|
| Relay | GPIO26 | 16A output |
| Switch Input | GPIO4 | Physical switch connection |
| Button | GPIO25 | Manual control |
| LED | GPIO0 | Status indicator |
| BL0942 RX | GPIO35 | UART power monitoring |
| NTC Sensor | GPIO32 | Temperature monitoring |

### Features

- ✅ **Power Monitoring** - Voltage, current, power, energy, frequency
- ✅ **Energy Tracking** - Compatible with Home Assistant Energy Dashboard
- ✅ **Temperature Monitoring** - Built-in NTC sensor
- ✅ **ESP32 Power** - Bluetooth support
- ✅ **16A Rating** - High current capacity

### Usage Example

```yaml
substitutions:
  device_name: space-heater
  friendly_name: "Space Heater"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  shelly:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - common/esp32-platform.yaml
      - common/esp32-ble.yaml
      - common/diagnostics.yaml
      - devices/shelly/plus-1pm.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### Community Notes

- **Tested ESPHome Versions:** 2024.11.0+
- **Use Cases:** High-power devices, appliance monitoring
- **Compared to Plus 1:** Adds power monitoring and temperature sensor

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
