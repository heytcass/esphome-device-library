# Contributing Guidelines

## Adding a New Device

### Requirements
1. Device must be fully functional with ESPHome
2. Configuration must be tested on actual hardware
3. Include calibration values if applicable
4. Provide clear documentation
5. Follow naming conventions

### File Structure
For device "Brand Model X":

```
devices/
  brand/
    model-x.yaml           # Hardware configuration
    model-x-project.yaml   # Dashboard import (optional)
```

### Configuration Standards
- Use entity_category appropriately
- Include diagnostic sensors
- Mark internal entities as internal: true
- Use descriptive entity names
- Include comments for non-obvious configurations

### Testing Checklist
- [ ] Configuration validates without errors
- [ ] Tested on actual hardware
- [ ] All entities appear in Home Assistant
- [ ] Power monitoring calibrated (if applicable)
- [ ] Buttons/switches work
- [ ] OTA updates work
- [ ] Safe mode works

### Pull Request Process
1. Fork the repository
2. Create device configuration
3. Test thoroughly
4. Update DEVICES.md
5. Submit PR with description and photos
6. Address review comments

## Development Environment

### NixOS Users

This repository includes a Nix flake for reproducible development:

```bash
# With direnv (automatic)
direnv allow

# Or manually
nix develop
```

All required tools (ESPHome, git, yamllint) are automatically available.

### Non-NixOS Users

Install ESPHome via pip:

```bash
pip install esphome
```

See [DEVELOPMENT.md](DEVELOPMENT.md) for full setup instructions.

## Code Style

### YAML Formatting
- Use 2 spaces for indentation
- Use lowercase for keys
- Add blank lines between major sections
- Comment non-obvious configurations

### Naming Conventions
- Device names: `brand-model` (lowercase, hyphenated)
- Entity names: Descriptive, title case
- Substitutions: `snake_case`
- IDs: `snake_case`

### Example Configuration Structure

```yaml
# Device-specific substitutions
substitutions:
  current_res: "0.001"
  voltage_div: "770"

# Board definition
esp32:
  board: esp32dev

# Sensors (group related components)
sensor:
  - platform: adc
    # ... configuration

# Binary sensors
binary_sensor:
  - platform: gpio
    # ... configuration

# Switches
switch:
  - platform: gpio
    # ... configuration
```

## Documentation

### Required Documentation
1. Add device to DEVICES.md with:
   - Complete specifications
   - GPIO pinout
   - Feature list
   - Usage example
   - Calibration notes
   - Known issues

2. Create example configuration in examples/

3. Add photos if possible:
   - Device exterior
   - PCB with GPIO labels
   - Serial connection points

## Community Guidelines

- Be respectful and welcoming
- Help others learn
- Share your knowledge
- Test thoroughly before submitting
- Document your work clearly

## Getting Help

- **ESPHome Discord** - Real-time community support
- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - General questions and ideas

Thank you for contributing! 🎉
