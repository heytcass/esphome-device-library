# ESPHome Device Library

[![Validate Configs](https://github.com/heytcass/esphome-device-library/actions/workflows/validate.yaml/badge.svg)](https://github.com/heytcass/esphome-device-library/actions/workflows/validate.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Community-maintained collection of **modern, DRY-compliant** ESPHome device configurations for popular smart home devices. Built with **ESPHome 2025 best practices** and modular architecture.

## ✨ What Makes This Library Different

- 🎯 **Strict DRY Principles** - Zero code duplication, maximum reusability
- 🚀 **ESPHome 2025 Features** - WiFi provisioning (USB + BLE), firmware updates, debug monitoring
- 📦 **Modular Architecture** - Mix and match common components (web server, BLE, diagnostics)
- 🔧 **Production Ready** - CI-validated, thoroughly tested configurations
- 📚 **Comprehensive Docs** - GPIO pinouts, calibration guides, flashing instructions

## 🎯 Supported Devices

| Device | Platform | Features | Status |
|--------|----------|----------|--------|
| [Wyze Outdoor Plug](devices/wyze/outdoor-plug.yaml) | ESP32 | Dual Outlets, Power Monitoring, BLE Proxy, Light Sensor | ✅ Stable |
| [Sonoff S31](devices/sonoff/s31.yaml) | ESP8266 | Power Monitoring, Compact Design, Web Server | ✅ Stable |
| [Athom Smart Plug V3](devices/athom/pg01v3-eu.yaml) | ESP32-C3 | 16A Power Monitoring, Pre-flashable, Power Factor | ✅ Stable |
| [AirGradient ONE v9](devices/airgradient/one-v9.yaml) | ESP32-C3 | PM2.5, CO2, VOC, NOx, Temp/Humidity, OLED Display | ✅ Stable |

## 🚀 Quick Start

### Method 1: ESPHome Dashboard (Easiest)

For dashboard-compatible devices (Athom, AirGradient), use the one-click install:

1. Open ESPHome Dashboard
2. Click "New Device" → "Continue" → "Skip"
3. Click "Edit" and paste the dashboard import URL from the [device page](docs/DEVICES.md)
4. Click "Install"

### Method 2: External Package Import (Recommended)

Use these device configurations directly in your ESPHome setup:

```yaml
substitutions:
  device_name: my-air-monitor
  friendly_name: "Office Air Quality"
  # Device-specific customizations (optional)
  led_strip_brightness: "20%"  # For AirGradient

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  base:
    url: https://github.com/heytcass/esphome-device-library
    ref: main  # or v1.0.0 for pinned version
    files:
      - common/base.yaml           # Core ESPHome services
      - common/esp32-platform.yaml # Platform config (ESP32/ESP8266/ESP32-C3)
      - common/diagnostics.yaml    # Sensors, switches, updates
      - common/web-server.yaml     # Optional: Web interface
      - devices/airgradient/one-v9.yaml  # Device hardware
    refresh: 1d

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

**Available common packages:**
- `common/base.yaml` - WiFi, API, OTA, logger, time sync, improv_serial
- `common/diagnostics.yaml` - WiFi signal, uptime, restart, debug monitoring
- `common/esp32-platform.yaml` - ESP32/ESP32-C3/ESP32-S3 framework
- `common/esp8266-platform.yaml` - ESP8266 framework
- `common/esp32-ble.yaml` - BLE tracker, Bluetooth proxy, esp32_improv
- `common/web-server.yaml` - Optional web interface (port 80)

### Method 3: Local Development (For Contributors)

#### For NixOS Users (Recommended)

```bash
# Clone the repository
git clone https://github.com/heytcass/esphome-device-library.git
cd esphome-device-library

# If you have direnv installed:
direnv allow
# ESPHome and all tools are now automatically available!

# Or manually enter the Nix development shell:
nix develop

# Validate a configuration
esphome config examples/local-development/airgradient-one-office.yaml
```

#### For Non-NixOS Users

```bash
# Clone the repository
git clone https://github.com/heytcass/esphome-device-library.git
cd esphome-device-library

# Install ESPHome
pip install esphome

# Copy and configure secrets
cp secrets.yaml.example secrets.yaml
# Edit secrets.yaml with your credentials

# Validate a configuration
esphome config examples/local-development/sonoff-s31-kitchen.yaml
```

## 🌟 Modern ESPHome 2025 Features

All devices in this library include cutting-edge ESPHome features:

### WiFi Provisioning (Dual Method)
- **`improv_serial`** - Configure WiFi via USB cable (all devices)
- **`esp32_improv`** - Configure WiFi via Bluetooth (ESP32 devices with BLE)

### Monitoring & Diagnostics
- **`update`** component - See available firmware updates in Home Assistant
- **`debug`** sensors - Heap free, max block size, loop time
- **Standard diagnostics** - WiFi signal, uptime, IP address, MAC, ESPHome version

### ESP32 Bluetooth Features
- **`bluetooth_proxy`** - Act as BLE gateway for Home Assistant
- **`esp32_ble_tracker`** - Track Bluetooth devices

### Web Interface (Optional)
- **`web_server`** - Built-in web UI for monitoring and control
- Include `common/web-server.yaml` to enable

## 📚 Documentation

- [**Device Catalog**](docs/DEVICES.md) - Complete specs, GPIO pinouts, calibration guides
- [**Development Guide**](docs/DEVELOPMENT.md) - Local setup and testing
- [**Contributing**](docs/CONTRIBUTING.md) - How to add new devices

## 🏗️ Repository Structure

```
├── common/             # Shared modular configurations (DRY principle)
│   ├── base.yaml              # Core ESPHome services
│   ├── diagnostics.yaml       # Monitoring & debug
│   ├── web-server.yaml        # Optional web UI
│   ├── esp32-platform.yaml    # ESP32 framework
│   ├── esp8266-platform.yaml  # ESP8266 framework
│   └── esp32-ble.yaml         # BLE features
├── devices/            # Device-specific hardware definitions
│   ├── airgradient/
│   ├── athom/
│   ├── sonoff/
│   └── wyze/
├── examples/           # Usage examples
│   ├── local-development/     # Using !include for local dev
│   └── external-package/      # Using GitHub URLs
├── docs/               # Comprehensive documentation
└── flake.nix          # NixOS development environment
```

## 🎨 Design Principles

This library follows **strict engineering principles**:

### DRY (Don't Repeat Yourself)
- Common components extracted to `common/` directory
- Zero duplicate restart/safe_mode switches across devices
- Modular web server configuration
- Shared diagnostic sensors

### Modularity
- Mix and match components (base + platform + device + optional packages)
- Optional features (web server, BLE) via separate includes
- Device-specific hardware isolated from common services

### Modern Best Practices (Oct 2025)
- Latest ESPHome component patterns
- Dual WiFi provisioning (USB + BLE)
- Debug monitoring built-in
- Firmware update notifications
- Entity categories for proper HA organization

### Production Quality
- CI validation on every commit
- Tested configurations
- Comprehensive documentation
- GPIO pinout tables
- Calibration instructions

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

**Want to add a device?**
1. Fork this repository
2. Set up development environment (see above)
3. Add device config following DRY principles
4. Update device catalog documentation
5. Add validation to CI workflow
6. Test thoroughly
7. Submit a pull request

## 📖 Development Environment

This repository includes a fully reproducible development environment using Nix flakes:

- **ESPHome** - Validation and compilation
- **Git** - Version control
- **Python** - Scripting support
- **yamllint** - YAML validation

NixOS users get automatic environment setup via `flake.nix` and `.envrc`. Non-NixOS users can use the repository normally with pip-installed ESPHome.

## 💡 Usage Tips

### Customize Entity Names
Use substitutions to customize sensor names per device:

```yaml
substitutions:
  device_name: bedroom-plug
  friendly_name: "Bedroom"
```

All sensors will be prefixed with your friendly name in Home Assistant.

### Mix and Match Packages
Don't need the web server? Just exclude it:

```yaml
packages:
  base: !include ../../common/base.yaml
  diagnostics: !include ../../common/diagnostics.yaml
  # web_server: !include ../../common/web-server.yaml  # Commented out
  hardware: !include ../../devices/sonoff/s31.yaml
```

### Pin to Specific Versions
For production use, pin to tagged releases:

```yaml
packages:
  base:
    url: https://github.com/heytcass/esphome-device-library
    ref: v1.0.0  # Pin to specific version
```

## 🎓 Learning Resources

New to ESPHome? Check out these resources:
- [ESPHome Official Docs](https://esphome.io/)
- [Home Assistant ESPHome Integration](https://www.home-assistant.io/integrations/esphome/)
- [ESPHome Discord Community](https://discord.gg/KhAMKrd)

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

## 🙏 Credits

- **ESPHome Team** - For the incredible platform
- **Community Contributors** - For device configurations and testing
- **Original Hardware Hackers** - For reverse engineering device pinouts
- **devices.esphome.io** - Inspiration and source of device specs

## 🔮 Roadmap

- [ ] Add more ESP32-C3 devices (low power, modern features)
- [ ] ESP32-S3 devices with camera support
- [ ] Matter protocol support (when ESPHome adds it)
- [ ] Automated device discovery
- [ ] Visual pin configurator

---

**Made with ❤️ for the Home Assistant and ESPHome community**

*Building the future of open-source smart home, one device at a time.*
