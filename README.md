# ESPHome Device Library

[![Validate Configs](https://github.com/heytcass/esphome-device-library/actions/workflows/validate.yaml/badge.svg)](https://github.com/heytcass/esphome-device-library/actions/workflows/validate.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Community-maintained ESPHome configurations with **automatic OTA updates**.

## What This Is

Unlike static config collections that rot over time, devices using this library **automatically receive updates** when the community improves calibration values, adds features, or fixes bugs.

**Currently Supported:**
| Device | Platform | Features |
|--------|----------|----------|
| [Wyze Outdoor Plug](devices/wyze/outdoor-plug.yaml) | ESP32 | Dual outlets, power monitoring, light sensor |
| [Sonoff S31](devices/sonoff/s31.yaml) | ESP8266 | Smart plug with power monitoring |
| [Sonocotta Louder ESP32-S3](devices/sonocotta/louder-esp32s3.yaml) | ESP32-S3 | TAS5805M DAC media player, Spotify Connect, 15-band EQ (**experimental**) |

## Quick Start (ESPHome Dashboard)

### 1. Create a new device

In ESPHome Dashboard: **New Device** → **Continue** → **Skip**

### 2. Paste this configuration

```yaml
substitutions:
  device_name: wyze-outdoor-plug-patio     # Change this! Must be unique
  friendly_name: "Patio Outdoor Plug"      # Change this! Shows in Home Assistant

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
      - common/esp32-platform.yaml
      - common/diagnostics.yaml
      - devices/wyze/outdoor-plug.yaml
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

### 3. Install

Click **Install** and choose your method (USB for first flash, then OTA works automatically).

### 4. WiFi Setup (First Boot)

After flashing, the device needs WiFi credentials:

1. **Connect to device AP**: Look for WiFi network `<friendly_name> Setup`
2. **Password**: `esphome123`
3. **Configure**: Browser opens automatically (or go to http://192.168.4.1)
4. **Enter your WiFi**: Submit your network SSID and password
5. **Done**: Device reboots and connects to your network

Credentials are stored in flash and persist across OTA updates.

After initial setup, the device checks for updates every 6 hours.

## How Automatic Updates Work

1. When new releases are published, GitHub Actions builds firmware
2. Firmware and manifests are deployed to GitHub Pages
3. Your device checks for updates and shows "Update Available" in Home Assistant
4. Click "Install" to update - no cables needed

## Important: Don't Adopt in ESPHome Dashboard

This project follows a **"productized" model** - firmware is pre-built and auto-updates centrally. This is different from typical ESPHome usage where you manage configs locally.

**If you "Adopt" a device in ESPHome Dashboard, you will break automatic updates.**

Here's why: When you adopt a device, Dashboard generates a unique API encryption key and takes over management. But HTTP OTA updates flash the pre-built firmware from GitHub, which doesn't have your unique key - your device becomes unreachable.

### Two Usage Models

| Model | Auto-Updates | API Encryption | Local Control |
|-------|--------------|----------------|---------------|
| **Productized** (this project) | ✅ Yes | ❌ No | ❌ No |
| **DIY** (traditional ESPHome) | ❌ No | ✅ Yes | ✅ Yes |

### For Auto-Updates (Recommended)

1. Flash the pre-built firmware
2. Use captive portal or Improv for WiFi setup
3. **Do NOT adopt** in ESPHome Dashboard
4. Device appears in Home Assistant automatically
5. Receive automatic updates when community improves configs

### For Full Local Control

If you need API encryption or want to customize configs:
1. Copy an [example file](examples/) to your local ESPHome
2. Modify as needed
3. Manage updates yourself (no automatic OTA from this repo)

## Project Structure

```
common/           # Shared packages (WiFi, OTA, diagnostics)
devices/          # Hardware-specific GPIO configs
firmware/         # Build configs for releases
examples/         # Templates to copy and customize
```

## Contributing

Want to add a new device? See [CONTRIBUTING.md](CONTRIBUTING.md) for step-by-step instructions.

## Architecture

See [PROJECT.md](PROJECT.md) for full architecture details and project vision.

## Links

- [ESPHome Documentation](https://esphome.io/)
- [Firmware Manifests](https://heytcass.github.io/esphome-device-library/)

## Acknowledgments

- [Sonocotta](https://github.com/sonocotta) - Louder ESP32-S3 hardware and TAS5805M integration

## License

MIT License - See [LICENSE](LICENSE) for details.
