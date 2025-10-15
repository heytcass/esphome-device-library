# ESPHome Device Library

[![Validate Configs](https://github.com/heytcass/esphome-device-library/actions/workflows/validate.yaml/badge.svg)](https://github.com/heytcass/esphome-device-library/actions/workflows/validate.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Community-maintained collection of ESPHome device configurations for popular smart home devices converted from proprietary firmware.

## 🎯 Supported Devices

| Device | Type | Features | Status |
|--------|------|----------|--------|
| [Wyze Outdoor Plug](devices/wyze/outdoor-plug.yaml) | Smart Plug | Power Monitoring, BLE Proxy, Dual Outlets | ✅ Stable |

## 🚀 Quick Start

### Method 1: External Package Import (Recommended for Users)

Use these device configurations directly in your ESPHome setup:

```yaml
substitutions:
  device_name: my-wyze-plug
  friendly_name: "Garden Lights"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  wyze:
    url: https://github.com/heytcass/esphome-device-library
    ref: main  # or v1.0.0 for pinned version
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

### Method 2: Local Development (For Contributors)

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
esphome config examples/local-development/wyzeoutdoor1.yaml
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
esphome config examples/local-development/wyzeoutdoor1.yaml
```

## 📚 Documentation

- [**Device Catalog**](docs/DEVICES.md) - Detailed device specifications and features
- [**Development Guide**](docs/DEVELOPMENT.md) - How to develop and test locally
- [**Contributing**](docs/CONTRIBUTING.md) - How to add new devices

## 🏗️ Repository Structure

```
├── common/           # Shared base configurations
├── devices/          # Device-specific hardware definitions
├── examples/         # Example configurations
├── docs/             # Documentation
└── flake.nix        # NixOS development environment
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

**Want to add a device?**
1. Fork this repository
2. Set up development environment (see above)
3. Add your device configuration
4. Test thoroughly
5. Submit a pull request

## 📖 Development Environment

This repository includes a fully reproducible development environment using Nix flakes:

- **ESPHome** - For validation and compilation
- **Git** - Version control
- **Python** - Scripting support
- **yamllint** - YAML validation

NixOS users get automatic environment setup. Non-NixOS users can still use the repository normally.

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

## 🙏 Credits

- ESPHome team for the amazing platform
- Community contributors who shared device configurations
- Original device hackers who figured out the hardware

---

**Made with ❤️ for the Home Assistant and ESPHome community**
