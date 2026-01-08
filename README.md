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

## Quick Start

### 1. Create secrets.yaml

```bash
cp secrets.yaml.example secrets.yaml
# Edit with your WiFi credentials and API key
```

Generate an API encryption key:
```bash
openssl rand -base64 32
```

### 2. Copy and customize an example

```bash
cp examples/wyze-outdoor-plug.yaml my-patio-plug.yaml
```

Edit `my-patio-plug.yaml` and change the substitutions:
```yaml
substitutions:
  device_name: wyze-outdoor-plug-patio     # Unique name for this device
  friendly_name: "Patio Outdoor Plug"      # Shows in Home Assistant
```

### 3. Flash your device

```bash
esphome run my-patio-plug.yaml
```

After initial flash via USB, the device will automatically check for updates every 6 hours.

## How Automatic Updates Work

1. When new releases are published, GitHub Actions builds firmware
2. Firmware and manifests are deployed to GitHub Pages
3. Your device checks for updates and shows "Update Available" in Home Assistant
4. Click "Install" to update - no cables needed

## Project Structure

```
common/           # Shared packages (WiFi, OTA, diagnostics)
devices/          # Hardware-specific GPIO configs
firmware/         # Build configs for releases
examples/         # Templates to copy and customize
```

## Architecture

See [PROJECT.md](PROJECT.md) for full architecture details, contribution guidelines, and project vision.

## Development

**NixOS users:** Environment auto-loads via direnv

**Others:**
```bash
pip install esphome
```

Validate a config:
```bash
esphome config examples/wyze-outdoor-plug.yaml
```

## Links

- [ESPHome Documentation](https://esphome.io/)
- [Firmware Manifests](https://heytcass.github.io/esphome-device-library/)

## License

MIT License - See [LICENSE](LICENSE) for details.
