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
| [Seeed reTerminal E1002](devices/seeed/reterminal-e1002.yaml) | ESP32-S3 | 7.3" 800x480 Spectra 6 ACeP e-paper, 3 buttons, piezo buzzer, SHT40 temp/humidity, battery + USB-C |

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
    ssid: "${device_name} Fallback"
```

### 3. Install

Click **Install** and choose your method (USB for first flash, then OTA works automatically).

### 4. WiFi Setup (First Boot)

After flashing, the device needs WiFi credentials:

1. **Connect to device AP**: Look for WiFi network `<device_name> Fallback`
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

Releases happen two ways, and both run the same pipeline:

- **Automatically, monthly.** On the 28th of each month CI rebuilds every device against the
  current ESPHome release and publishes the next patch version, so devices keep receiving
  ESPHome updates (security fixes included) without waiting on a maintainer. ESPHome ships
  its monthly release on the third Wednesday, so the 28th lands a week or so later — after
  the first round of patch releases, rather than on day-one `.0`. If neither ESPHome nor this
  repo has changed since the last release, the run stops early rather than reflashing your
  devices with identical firmware. If a rebuild fails, CI opens an issue.
- **On demand.** Run the **Build Firmware** workflow with a version (e.g. `v3.1.0`), or push
  a `v*` tag. Use this for changes that shouldn't wait for the monthly train.

## Two Usage Models

This project supports both **productized** (auto-updating) and **adoptable** (customizable) workflows using the same firmware.

| Model | Auto-Updates | Customizable | Best For |
|-------|--------------|--------------|----------|
| **Productized** | ✅ Yes | ❌ No | Set-and-forget devices |
| **Adopted** | ❌ No | ✅ Yes | Power users who want control |

### Productized (Auto-Updates)

1. Flash the pre-built firmware from [GitHub Releases](https://github.com/heytcass/esphome-device-library/releases)
2. Use captive portal or Improv for WiFi setup
3. Don't adopt in ESPHome Dashboard
4. Device receives automatic updates when community improves configs

### Adopted (Full Control)

1. Flash the pre-built firmware
2. **Adopt** the device in ESPHome Dashboard
3. Dashboard imports the base config (without HTTP OTA)
4. Customize freely - you manage updates locally

This follows the [Home Assistant Voice PE pattern](https://github.com/esphome/home-assistant-voice-pe) where factory firmware includes auto-updates, but adopted devices get a clean base config.

## Project Structure

```
common/           # Shared packages (WiFi, OTA, diagnostics)
devices/          # Hardware-specific GPIO configs
firmware/
  ├── device.yaml          # Base config (adoptable, no HTTP OTA)
  └── device.factory.yaml  # Factory config (extends base + HTTP OTA + improv)
examples/         # Templates to copy and customize
```

**Base configs** (`device.yaml`) contain all device functionality and are what users get when adopting.
**Factory configs** (`device.factory.yaml`) extend base with productized features (HTTP OTA, Improv, dashboard_import).

## Security Model

Shared, pre-built firmware cannot contain per-device secrets, so this project is explicit
about what is protected and what is a documented trade-off:

- **API encryption — per-device keys, provisioned at runtime.** Firmware ships keyless
  (`api: encryption:` with no key). Home Assistant generates a unique key for each device on
  first connection and the device stores it in flash, where it survives OTA updates. Devices
  updating from older unencrypted firmware re-provision on first connect — Home Assistant may
  prompt once per device. Adopted devices get their key from the ESPHome Device Builder as
  before.
- **Local OTA password is public by design.** The password on the standard ESPHome OTA port
  is in this repo, so it is not a secret — it exists to stop drive-by scanners and
  mass-exploitation scripts on your LAN, not a determined attacker who has read the source.
  Override it in your own config (`!extend ota_esphome`) if you want a private one.
- **ESP8266 update channel is not authenticated.** ESP8266 devices (like the Sonoff S31)
  fetch update manifests and firmware with `verify_ssl: false` because the ESP8266 TLS stack
  cannot do full certificate verification; the MD5 checksum is integrity-only. An attacker
  who already controls your network path could serve forged firmware to ESP8266 devices.
  ESP32 devices verify TLS fully and are not affected. If this is outside your threat model
  for a smart plug, adopt the device instead and manage updates locally.
- **Fallback AP password is fleet-wide and public** (`esphome123`). The AP only exists while
  the device has no working WiFi (first boot, or your network is down); someone within radio
  range during that window could join it and reconfigure the device's WiFi. Prefer Improv
  (USB/BLE) provisioning where available.

## Contributing

Want to add a new device? See [CONTRIBUTING.md](CONTRIBUTING.md) for step-by-step instructions.

## Architecture

See [PROJECT.md](PROJECT.md) for full architecture details and project vision.

## Links

- [ESPHome Documentation](https://esphome.io/)
- [Firmware Manifests](https://heytcass.github.io/esphome-device-library/)

## License

MIT License - See [LICENSE](LICENSE) for details.
