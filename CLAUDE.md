# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a community-maintained collection of ESPHome device configurations for popular smart home devices. The repository provides reusable, modular YAML configurations that can be imported as packages into user ESPHome setups.

## Development Environment

### NixOS Users (Recommended)
The repository includes a Nix flake with all required tools. Enter the dev environment:

```bash
nix develop           # Manual shell entry
direnv allow          # Automatic with direnv
```

Tools provided: `esphome`, `git`, `python`, `yamllint`

### Non-NixOS Users
Install ESPHome via pip:
```bash
pip install esphome
```

## Common Commands

### Validation
```bash
# Validate a single configuration
esphome config examples/local-development/wyzeoutdoor1.yaml

# Validate all local examples
for file in examples/local-development/*.yaml; do
  esphome config "$file"
done
```

### Compilation
```bash
# Compile firmware (doesn't flash)
esphome compile examples/local-development/wyzeoutdoor1.yaml

# Check generated binary
ls -lh .esphome/build/wyzeoutdoor1/.pioenvs/wyzeoutdoor1/firmware.bin
```

### CI Validation
GitHub Actions validates all configs in `examples/local-development/` on push/PR.

## Architecture

### Package Layer System

The repository uses a hierarchical package structure that allows users to compose device configurations:

```
Layer 1: common/base.yaml
├── Universal services: API, OTA, Logger, WiFi, mDNS, Safe Mode
└── Platform-agnostic, works on ANY ESP device

Layer 2: common/esp32-platform.yaml OR common/esp8266-platform.yaml
├── ESP32/ESP8266 framework configuration
└── Choose based on device chipset

Layer 3: common/esp32-ble.yaml (optional)
├── BLE tracker and bluetooth_proxy
└── Only include for BLE-capable ESP32 devices

Layer 4: common/diagnostics.yaml
├── WiFi signal, uptime, restart count sensors
└── Standard monitoring for all devices

Layer 5: devices/brand/model.yaml
├── Hardware-specific GPIO definitions
├── Device-specific sensors (power monitoring, etc.)
├── Switches, buttons, LEDs
└── Board type (esp32dev, esp01_1m, etc.)
```

### Secrets Management

The repository uses `!secret` references that resolve from:
1. Local development: `secrets.yaml` (git-ignored, user-created from template)
2. External package imports: User's own secrets in their ESPHome setup
3. GitHub Actions: Generated dummy `secrets.yaml` for validation

Required secrets:
- `wifi_ssid`, `wifi_password`
- `api_encryption_key`
- `ota_password`
- `ap_password`

### Example Configuration Pattern

Local development examples follow this pattern:

```yaml
substitutions:
  device_name: unique-device-id
  friendly_name: "Human Readable Name"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  base: !include ../../common/base.yaml
  platform: !include ../../common/esp32-platform.yaml
  ble: !include ../../common/esp32-ble.yaml          # Optional
  diagnostics: !include ../../common/diagnostics.yaml
  hardware: !include ../../devices/brand/model.yaml

wifi:
  ap:
    ssid: "${friendly_name} Fallback"
```

External package imports use GitHub URLs instead of `!include`:
```yaml
packages:
  device:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - devices/wyze/outdoor-plug.yaml
```

## Adding a New Device

### File Structure
For device "Brand Model X":
```
devices/
  brand/
    model-x.yaml           # Hardware configuration
    model-x-project.yaml   # Dashboard import (optional)
examples/
  local-development/
    model-x-test.yaml      # Local testing example
  external-package/
    model-x-example.yaml   # External import example
```

### Required Elements in Device YAML

1. **Board specification**: Must be defined in device YAML
   ```yaml
   esp32:
     board: esp32dev
   ```

2. **Substitutions**: For calibration values
   ```yaml
   substitutions:
     current_res: "0.001"
     voltage_div: "770"
   ```

3. **Hardware components**: GPIO pins, sensors, switches
   - Use `entity_category: diagnostic` for technical sensors
   - Use `internal: true` for hidden entities
   - Use descriptive names (shown in Home Assistant)

4. **Proper ESPHome entity configuration**:
   - Include `device_class` and `state_class` for sensors
   - Add `restore_mode` for switches
   - Use filters for calibration and noise reduction

### Validation Workflow

1. Create device configuration in `devices/brand/model.yaml`
2. Create example in `examples/local-development/test.yaml`
3. Validate: `esphome config examples/local-development/test.yaml`
4. Fix errors iteratively
5. Add to CI: Update `.github/workflows/validate.yaml` matrix
6. Document in `docs/DEVICES.md`

## Code Style

### YAML Conventions
- 2 spaces for indentation
- Lowercase keys
- Descriptive entity names (Title Case)
- `snake_case` for IDs and substitutions
- `brand-model` for device names (lowercase, hyphenated)
- Comment non-obvious configurations

### Entity Naming
- **name**: Human-readable, shows in Home Assistant ("Outlet 1", "Current")
- **id**: Internal reference, snake_case (relay1, power_sensor)
- Use `internal: true` to hide from Home Assistant
- Use `entity_category: diagnostic` for technical info

## Testing Checklist

Before submitting a device configuration:
- [ ] Configuration validates without errors
- [ ] Tested on actual hardware
- [ ] All entities appear in Home Assistant
- [ ] Power monitoring calibrated (if applicable)
- [ ] Buttons/switches work correctly
- [ ] OTA updates work
- [ ] Safe mode works

## Common Pitfalls

1. **Forgetting board type**: Device YAML must specify `esp32.board` or `esp8266.board`
2. **Invalid GPIO pins**: Check device-specific pinout
3. **Missing secrets**: Local dev requires `secrets.yaml` (never commit this)
4. **Wrong platform layer**: ESP8266 devices need `esp8266-platform.yaml`, not `esp32-platform.yaml`
5. **BLE on non-ESP32**: BLE only works on ESP32, not ESP8266

## Git Workflow

Always use the `git cc-commit-msg` command for commits (configured for YubiKey GPG signing):

```bash
git checkout -b add-new-device
# Make changes
esphome config examples/local-development/test.yaml
git add .
git cc-commit-msg "Add support for Brand Model X"
git push origin add-new-device
```

## Debugging

### Clear ESPHome cache
```bash
rm -rf .esphome
```

### Verbose logging
Add to test config:
```yaml
logger:
  level: DEBUG
```

### Check for hidden characters
```bash
cat -A file.yaml
```

### Verify YAML syntax
```bash
python -c "import yaml; yaml.safe_load(open('file.yaml'))"
```
