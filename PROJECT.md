# ESPHome Device Library - Project Vision & Standards

## The Problem We're Solving

**Device configs become stagnant after they're published.**

The official https://devices.esphome.io/ database is a valuable resource that's actively growing with new device contributions. But once a config is added, it rarely gets updated. Better calibration values, new ESPHome features, security fixes - they all get shared in Discord threads and forum posts where they're impossible to find. Every user ends up maintaining their own fork of configs that slowly drift apart.

## The Solution: Living, Auto-Updating Configs

This repository provides **community-maintained ESPHome configurations** that:

1. **Auto-update to devices** via HTTP OTA from GitHub Releases
2. **Improve over time** as the community contributes better calibration, new features, and bug fixes
3. **Follow DRY principles** with a modular package hierarchy that makes contributions easy
4. **Actually get tested** because contributors use these configs on real devices

**The cornerstone feature is HTTP OTA.** Everything else is just ESPHome configuration. HTTP OTA is what makes this a living system instead of another static config dump.

---

## North Star Principles

### 1. HTTP OTA IS NOT OPTIONAL
Every device config MUST support HTTP OTA updates from GitHub Releases. This is the entire point. A device without HTTP OTA is just a config file - it doesn't belong here.

### 2. DRY ABOVE ALL ELSE
Extract EVERYTHING reusable into common packages. Device files contain ONLY hardware-specific GPIO mappings and calibration. If two devices could share it, it belongs in `common/`.

### 3. WORKING > FEATURES
A simple config with reliable OTA beats an elaborate config that bricks devices. Stability first, features second.

### 4. COMMUNITY MAINTAINABLE
Configs should be easy to understand, modify, and contribute to. Clear package boundaries, good documentation, consistent patterns.

---

## Project Phases

### Phase 1: Prove the Architecture (CURRENT)
**Focus Device**: Wyze Outdoor Plug

Goal: Validate that the entire flow works:
- Modular package hierarchy (common -> platform -> device)
- GitHub Actions builds firmware on release
- HTTP OTA updates devices automatically
- Community can contribute improvements

**Exit Criteria for Phase 1**:
- [ ] Wyze Outdoor Plug compiles and flashes successfully
- [ ] Device receives HTTP OTA updates from GitHub Releases
- [ ] Home Assistant shows firmware update entity
- [ ] At least one real device running in production

### Phase 2: Template & Documentation
Once Wyze is proven, document the pattern for adding new devices:
- Contribution guide with clear steps
- Device template showing package structure
- CI/CD automatically validates new device configs

### Phase 3: Community Expansion
Open for community contributions of additional devices:
- Sonoff, Athom, Shelly, etc.
- Each device follows established patterns
- Maintainers review for quality and DRY compliance

---

## Architecture

```
esphome-device-library/
├── common/                      # Reusable packages (everyone uses these)
│   ├── base.yaml               # WiFi, API, OTA, logger, time, mDNS
│   ├── esp32-platform.yaml     # ESP32 framework config
│   ├── esp8266-platform.yaml   # ESP8266 framework config
│   ├── diagnostics.yaml        # WiFi signal, uptime, debug sensors
│   ├── http-ota.yaml           # HTTP firmware updates (REQUIRED)
│   └── secrets.yaml            # Include directive for ../secrets.yaml
│
├── devices/                     # Hardware definitions (one per device model)
│   └── wyze/
│       └── outdoor-plug.yaml   # GPIO pins, power monitoring, buttons, LEDs
│
├── firmware/                    # Build configurations (one per device)
│   └── wyze-outdoor-plug.yaml  # Combines packages for firmware build
│
├── examples/                    # User-facing examples
│   └── wyze-outdoor-plug.yaml  # Template users copy and customize
│
├── .github/workflows/
│   ├── validate.yaml           # CI: validates all configs
│   └── build-firmware.yaml     # Release: builds firmware, deploys to GitHub Pages
│
├── secrets.yaml.example        # Template for user secrets
├── PROJECT.md                  # THIS DOCUMENT - vision and standards
└── README.md                   # User-facing quick start
```

### Package Layers

| Layer | File | Purpose |
|-------|------|---------|
| 1 | `common/base.yaml` | WiFi, API, OTA, logger, time, mDNS - universal services |
| 2 | `common/esp*-platform.yaml` | Platform framework config (ESP32/ESP8266) |
| 3 | `common/diagnostics.yaml` | WiFi signal, uptime, debug sensors |
| 4 | `common/http-ota.yaml` | HTTP OTA updates (REQUIRED for all devices) |
| 5 | `devices/*/[device].yaml` | Hardware-specific GPIO mappings only |

---

## HTTP OTA Flow

```
1. Maintainer creates GitHub Release (e.g., v1.0.9)
2. build-firmware.yaml workflow:
   - Compiles firmware for each device in matrix
   - Generates .bin, .md5, -manifest.json for each
   - Uploads to GitHub Release assets
   - Deploys manifests to GitHub Pages
3. Devices check manifest every 6 hours:
   URL: https://heytcass.github.io/esphome-device-library/${firmware_name}-manifest.json
4. Home Assistant shows "Update Available" when new version detected
5. User clicks "Install" -> device downloads and flashes new firmware
```

**This is the entire point of the project.** If HTTP OTA doesn't work, nothing else matters.

---

## Adding New Devices (Phase 2+)

1. **Create hardware file**: `devices/brand/model.yaml`
   - Board type and improv_serial
   - GPIO mappings
   - Hardware-specific sensors
   - Set `firmware_name` substitution

2. **Create firmware build**: `firmware/brand-model.yaml`
   - Import all common packages (http-ota.yaml is REQUIRED)
   - Import hardware file

3. **Create example**: `examples/brand-model.yaml`

4. **Update CI**: Add to validate.yaml and build-firmware.yaml matrices

5. **Test on real hardware**: Validate, compile, flash, verify HTTP OTA works

---

## Quality Standards

### Every Device MUST:
- Include http-ota.yaml (non-negotiable)
- Have a firmware/ build config
- Have an examples/ template
- Be in CI validation and build matrices
- Be tested on real hardware

### Code MUST:
- Follow DRY - no duplication between device files
- Use substitutions for calibration values
- Include improv_serial for easy WiFi setup
- Set firmware_name matching the manifest filename

---

## Session Checklist for Claude Agents

Before making ANY change:

1. Does this support the HTTP OTA auto-update mission?
2. Is this aligned with current phase goals?
3. Am I reducing complexity or adding it?
4. Am I duplicating something that should be in common/?
5. Will CI still pass after this change?
6. Have I tested this actually works?

### Anti-Patterns to Avoid:
- Adding devices before current phase is complete
- Creating "optional" packages (http-ota is REQUIRED)
- Building firmware for untested devices
- Over-engineering for hypothetical future needs
- Adding features before core OTA flow works

---

## Links

- **Source**: https://github.com/heytcass/esphome-device-library
- **Firmware Manifests**: https://heytcass.github.io/esphome-device-library/
- **Reference**: https://devices.esphome.io/ (official ESPHome device database)
