# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a modular ESPHome device library that follows strict DRY principles. Configurations are broken into reusable layers that can be mixed and matched via ESPHome's package system.

## Core Architecture

### Five-Layer Package System

The architecture uses ESPHome's package inheritance system to avoid code duplication:

```
Layer 1: common/base.yaml          → Core services (WiFi, API, OTA, logger, time, mDNS)
Layer 2: common/esp*-platform.yaml → Platform-specific framework config
Layer 3: common/diagnostics.yaml   → Standard monitoring sensors
Layer 4: devices/brand/model.yaml  → Hardware-specific GPIO/sensors
Layer 5: Optional packages         → web-server.yaml, static-ip.yaml, esp32-ble.yaml
```

**Critical Pattern**: Device configurations should NEVER contain duplicated services. If a component is needed by multiple devices, it belongs in `common/`.

### Package Import Methods

Two import methods are supported:

1. **Local development** (`!include` directive):
   ```yaml
   packages:
     base: !include ../../common/base.yaml
     hardware: !include ../../devices/sonoff/s31.yaml
   ```

2. **External users** (GitHub URLs):
   ```yaml
   packages:
     base:
       url: https://github.com/heytcass/esphome-device-library
       ref: main
       files: [common/base.yaml, devices/sonoff/s31.yaml]
       refresh: 1d
   ```

**Important**: Every device MUST have an example configuration in `examples/local-development/` for CI validation.

### Dashboard Import Pattern (Optional)

Devices can optionally include a `*-project.yaml` file for ESPHome Dashboard one-click installation:

```yaml
dashboard_import:
  package_import_url: github://heytcass/esphome-device-library/devices/brand/model-project.yaml@main
  import_full_config: false

packages:
  base: github://heytcass/esphome-device-library/common/base.yaml@main
  hardware: github://heytcass/esphome-device-library/devices/brand/model.yaml@main
```

This allows users to install directly from the ESPHome Dashboard without manually creating config files.

### Secrets Management

All sensitive data uses ESPHome's `!secret` directive:
- `secrets.yaml.example` contains template with comments
- `secrets.yaml` (gitignored) contains actual values
- CI workflow creates minimal secrets for validation

**First-time setup**:
```bash
cp secrets.yaml.example secrets.yaml
# Edit secrets.yaml with your actual WiFi credentials and keys
```

## Essential Commands

### Validation
```bash
# Validate single configuration
esphome config examples/local-development/device-name.yaml

# Validate all examples (mirrors CI)
for file in examples/local-development/*.yaml; do
  esphome config "$file"
done
```

### Compilation (Optional)
```bash
# Compile without flashing (verifies code generation)
esphome compile examples/local-development/device-name.yaml

# Output location: .esphome/build/device-name/.pioenvs/device-name/firmware.bin
```

### Development Environment

**NixOS users**: Environment auto-loads via direnv (flake.nix provides esphome, yamllint, git)

**Non-NixOS users**: Install ESPHome manually:
```bash
pip install esphome
```

## Key Patterns and Conventions

### Adding New Devices

1. **Create hardware config**: `devices/brand/model.yaml`
   - Define board type (esp32/esp8266/esp32c3)
   - Define GPIO pins and device-specific sensors
   - Use substitutions for calibration values
   - Include `improv_serial` component for USB WiFi provisioning
   - DO NOT include base services (WiFi, API, OTA) - those are in common/base.yaml

2. **Create example config**: `examples/local-development/device-test.yaml`
   - Include device-specific substitutions (device_name, friendly_name)
   - Import all necessary packages (base + platform + hardware + optional)
   - This is what CI will validate

3. **Add to CI matrix**: `.github/workflows/validate.yaml`
   - Add new example file to the matrix.config list

4. **Document**: `docs/DEVICES.md`
   - GPIO pinout table
   - Calibration notes
   - Feature list

### Optional Packages

Optional features are separate includes to keep base configs minimal:

- `common/http-ota.yaml` - **HTTP-based OTA updates** - Enables automatic firmware updates from GitHub Releases. Devices check for updates every 6 hours and can be updated via Home Assistant with one click.
- `common/web-server.yaml` - Adds web UI on port 80
- `common/static-ip.yaml` - For networks with mDNS issues (requires substitution: wifi_static_ip; requires secrets: wifi_gateway, wifi_subnet)
- `common/esp32-ble.yaml` - BLE proxy and tracker (ESP32 only)

Include these AFTER base.yaml to override/extend functionality.

#### HTTP OTA Updates - Automated Firmware Distribution

The `http-ota.yaml` package enables devices to pull firmware updates from GitHub Releases:

**How it works:**
1. GitHub Actions automatically builds firmware binaries when releases are published
2. Binaries and JSON manifests are uploaded to GitHub Releases
3. Devices check the manifest every 6 hours to detect new versions
4. Users trigger updates via Home Assistant (Settings → System → Updates)

**Configuration:**
```yaml
packages:
  base: !include ../../common/base.yaml
  http_ota: !include ../../common/http-ota.yaml  # Add this line
  platform: !include ../../common/esp8266-platform.yaml
  # ... other packages
```

**Requirements:**
- `${firmware_name}` substitution must be set (typically in the hardware device file)
- Device needs internet access to GitHub
- Firmware binaries are built automatically via `.github/workflows/build-firmware.yaml`

**Triggering updates:**
- **Home Assistant**: Settings → System → Updates, or click "Update" on the firmware entity
- **Force check**: Call `homeassistant.update_entity` service on the firmware update entity
- **On boot**: Devices check for updates when they start

**GitHub Release workflow:**
- Releases trigger the build workflow automatically
- Each device gets: `.bin` (firmware), `.md5` (checksum), `-manifest.json` (version info)
- Manifest URL pattern: `https://github.com/USER/REPO/releases/latest/download/DEVICE_NAME-manifest.json`

### Naming Conventions

- **Files**: `brand-model.yaml` (lowercase, hyphenated)
- **Device names**: `brand-model-location` (e.g., sonoff-s31-kitchen)
- **Substitutions**: `snake_case`
- **Entity IDs**: `snake_case`
- **Friendly names**: Title Case (used in Home Assistant)

### Entity Organization

Follow ESPHome entity_category patterns:
- `entity_category: diagnostic` - WiFi signal, uptime, IP address
- `entity_category: config` - Configuration entities (restart button, safe mode)
- No category - User-facing sensors/switches (power monitoring, relays)

## CI/CD Workflows

### Validation Workflow (`.github/workflows/validate.yaml`)

Runs on every push and pull request:
- Matrix strategy tests each example independently
- Creates dummy secrets.yaml for validation
- Runs `esphome config` (validation only, no compilation)

**When adding devices**: Always add corresponding example to validation matrix.

### Build Firmware Workflow (`.github/workflows/build-firmware.yaml`)

Runs on GitHub Releases and manual trigger:
- Compiles firmware binaries for all device configurations
- Generates MD5 checksums for integrity verification
- Generates JSON manifests with version info for OTA detection
- Uploads `.bin`, `.md5`, and `-manifest.json` files to GitHub Releases
- Enables HTTP-based OTA updates for devices using `common/http-ota.yaml`

**To publish new firmware:**
1. Create a new GitHub Release (e.g., `v1.0.0`)
2. Workflow automatically builds and attaches firmware binaries + manifests
3. Devices with HTTP OTA enabled will detect the update within 6 hours (or on next boot)

## Common Gotchas

1. **Platform-specific components**: Don't use ESP32-only components (like BLE) in ESP8266 devices
2. **GPIO conflicts**: Check device pinouts carefully - some pins are reserved for flash/boot
3. **Secrets in CI**: CI uses dummy values - validation doesn't need real WiFi credentials
4. **Package order matters**: base.yaml should be first, hardware last, optionals can override
5. **Static IP usage**: Each device needs its own IP in substitutions (wifi_static_ip), while network config (gateway, subnet) goes in secrets

## Modern ESPHome Features (2025)

This library uses current best practices:
- `improv_serial` - USB WiFi provisioning (all devices)
- `esp32_improv` - Bluetooth WiFi provisioning (ESP32 with BLE)
- `update` component - Firmware update notifications in HA
- `debug` component - Heap/loop time monitoring
- `safe_mode` - Automatic fallback on boot failures
- `captive_portal` - Fallback AP with setup portal
