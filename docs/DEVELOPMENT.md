# Development Guide

This guide covers local development for the ESPHome Device Library.

## Table of Contents

- [Development Setup](#development-setup)
- [NixOS Workflow](#nixos-workflow)
- [Non-NixOS Workflow](#non-nixos-workflow)
- [Validation](#validation)
- [Testing Changes](#testing-changes)
- [Package Structure](#package-structure)

## Development Setup

### For NixOS Users

The repository includes a Nix flake for a fully reproducible development environment.

#### Option 1: With direnv (Automatic - Recommended)

```bash
# Install direnv if not already installed (add to configuration.nix):
programs.direnv.enable = true;
programs.direnv.nix-direnv.enable = true;

# Clone and enter directory
git clone https://github.com/heytcass/esphome-device-library.git
cd esphome-device-library

# Allow direnv
direnv allow

# That's it! ESPHome and tools are automatically available
esphome config examples/local-development/wyzeoutdoor1.yaml
```

#### Option 2: Manual Nix Shell

```bash
# Clone repository
git clone https://github.com/heytcass/esphome-device-library.git
cd esphome-device-library

# Enter development shell
nix develop

# Now you have access to all tools
esphome config examples/local-development/wyzeoutdoor1.yaml

# Exit shell when done
exit
```

#### What's Included in the Nix Environment

- `esphome` - For configuration validation and compilation
- `git` - Version control
- `python` - For any scripting needs
- `yamllint` - YAML file validation

### For Non-NixOS Users

```bash
# Install ESPHome
pip install esphome

# Or use a virtual environment
python -m venv venv
source venv/bin/activate
pip install esphome

# Clone repository
git clone https://github.com/heytcass/esphome-device-library.git
cd esphome-device-library
```

## NixOS Workflow

### Quick Validation

```bash
cd esphome-device-library  # direnv loads environment automatically

# Validate a single file
esphome config examples/local-development/wyzeoutdoor1.yaml

# Validate all examples
for file in examples/local-development/*.yaml; do
  echo "Validating $file..."
  esphome config "$file"
done
```

### Full Compilation Test

```bash
# Compile firmware (doesn't flash, just builds)
esphome compile examples/local-development/wyzeoutdoor1.yaml

# Check the generated binary
ls -lh .esphome/build/wyzeoutdoor1/.pioenvs/wyzeoutdoor1/firmware.bin
```

### Working with Secrets

```bash
# Create secrets file from template
cp secrets.yaml.example secrets.yaml

# Edit with your credentials (never commit this!)
$EDITOR secrets.yaml
```

## Non-NixOS Workflow

Same as above, but ensure you've activated your Python virtual environment or have ESPHome installed globally.

## Validation

### Quick Validation

```bash
# Validate single file
esphome config <file.yaml>

# Success output:
INFO Reading configuration <file.yaml>...
INFO Configuration is valid!
```

### Common Validation Errors

```yaml
# ❌ Invalid GPIO pin
pin: GPIO99  # ESP32 doesn't have GPIO99

# ❌ Missing required field
sensor:
  - platform: adc
    # Missing 'pin' field

# ❌ Typo in component name
sensro:  # Should be 'sensor'
  - platform: adc

# ❌ Invalid substitution reference
${non_existent_variable}
```

### YAML Linting (NixOS only, included in flake)

```bash
# Lint YAML files for style issues
yamllint devices/wyze/outdoor-plug.yaml

# Lint all YAML files
yamllint .
```

## Testing Changes

### Local Development Testing

1. **Make changes** to configuration files
2. **Validate** with `esphome config`
3. **Commit** when validation passes

```bash
# Make changes
vim devices/wyze/outdoor-plug.yaml

# Validate
esphome config examples/local-development/wyzeoutdoor1.yaml

# If valid, commit
git add devices/wyze/outdoor-plug.yaml
git commit -m "Update power monitoring calibration"
```

### Testing External Package Imports

Test that external package imports work correctly:

```bash
# Create a test file outside the repo
cd /tmp
cat > test-external.yaml << 'EOF'
substitutions:
  device_name: test-device
  friendly_name: "Test Device"

esphome:
  name: ${device_name}

packages:
  test:
    url: https://github.com/heytcass/esphome-device-library
    ref: main
    files:
      - common/base.yaml
      - devices/wyze/outdoor-plug.yaml
    refresh: 1d
EOF

# Validate (requires internet)
esphome config test-external.yaml
```

## Package Structure

### Understanding the Package Layers

```
Layer 1: common/base.yaml
├── API, OTA, Logger, WiFi, mDNS
└── Works on ANY platform

Layer 2: common/esp32-platform.yaml
├── ESP32 framework configuration
└── Works for all ESP32 variants

Layer 3: common/esp32-ble.yaml (optional)
├── BLE tracker and bluetooth_proxy
└── Only include for BLE-capable devices

Layer 4: common/diagnostics.yaml
├── WiFi signal, uptime, status sensors
└── Standard monitoring for all devices

Layer 5: devices/brand/model.yaml
├── Hardware-specific GPIO definitions
├── Device-specific sensors
└── Unique features per device
```

### Creating a New Device Configuration

```bash
# 1. Create device directory
mkdir -p devices/newbrand

# 2. Create hardware definition
vim devices/newbrand/new-device.yaml

# 3. Specify the board
# Include in YAML:
esp32:
  board: esp32dev  # or appropriate board

# 4. Add hardware components
# (GPIO pins, sensors, switches, etc.)

# 5. Create example configuration
vim examples/local-development/new-device-test.yaml

# 6. Validate
esphome config examples/local-development/new-device-test.yaml

# 7. Document in DEVICES.md
vim docs/DEVICES.md
```

## Development Tips

### Rapid Iteration

```bash
# Use file watching to validate on save (requires entr)
ls examples/local-development/*.yaml | entr -c esphome config /_
```

### Debug Logging

```yaml
# Add to your test config for verbose output
logger:
  level: DEBUG
  logs:
    component: DEBUG
```

### Comparing Compiled Outputs

```bash
# Compile two configs and compare
esphome compile old-config.yaml
esphome compile new-config.yaml
diff .esphome/build/old/.pioenvs/old/src/* .esphome/build/new/.pioenvs/new/src/
```

## Git Workflow

```bash
# Create feature branch
git checkout -b add-new-device

# Make changes and validate
esphome config examples/local-development/wyzeoutdoor1.yaml

# Commit
git add .
git commit -m "Add support for New Device X"

# Push and create PR
git push origin add-new-device
```

## Troubleshooting

### Nix Issues

```bash
# Update flake inputs
nix flake update

# Rebuild development shell
nix develop --refresh

# Clear direnv cache
direnv reload
```

### ESPHome Issues

```bash
# Clear ESPHome cache
rm -rf .esphome

# Reinstall dependencies (non-NixOS)
pip install --upgrade esphome
```

### Validation Fails but Config Looks Correct

```bash
# Check for hidden characters
cat -A file.yaml

# Verify YAML syntax
python -c "import yaml; yaml.safe_load(open('file.yaml'))"
```

## Next Steps

- Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Check [DEVICES.md](DEVICES.md) for device-specific details
- Join the ESPHome Discord for community support
