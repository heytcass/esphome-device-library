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

### Phase 1: Prove the Architecture (COMPLETE)
**Focus Device**: Wyze Outdoor Plug

Goal: Validate that the entire flow works:
- Modular package hierarchy (common -> platform -> device)
- GitHub Actions builds firmware on release
- HTTP OTA updates devices automatically
- Community can contribute improvements

**Exit Criteria for Phase 1**:
- [x] Wyze Outdoor Plug compiles and flashes successfully
- [x] Device receives HTTP OTA updates from GitHub Releases
- [x] Home Assistant shows firmware update entity
- [x] At least one real device running in production

*Completed: January 2026 (v2.0.4)*

### Phase 2: Template & Documentation (COMPLETE)
Once Wyze is proven, document the pattern for adding new devices:
- Contribution guide with clear steps
- Device template showing package structure
- CI/CD automatically validates new device configs

**Exit Criteria for Phase 2**:
- [x] CONTRIBUTING.md with step-by-step device addition guide
- [x] WiFi provisioning flow documented in README
- [x] Example file serves as clear template for new devices
- [x] CI validates all example configs

*Completed: January 2026*

### Phase 3: Community Expansion (CURRENT)
Open for community contributions of additional devices:
- Sonoff, Athom, Shelly, etc.
- Each device follows established patterns
- Maintainers review for quality and DRY compliance

---

## Architecture

This project follows the [Home Assistant Voice PE pattern](https://github.com/esphome/home-assistant-voice-pe) with separate base and factory configs.

```
esphome-device-library/
├── common/                      # Reusable packages (everyone uses these)
│   ├── base.yaml               # WiFi, API, OTA, logger, time, mDNS
│   ├── esp32-platform.yaml     # ESP32 framework config
│   ├── esp8266-platform.yaml   # ESP8266 framework config
│   ├── diagnostics.yaml        # WiFi signal, uptime, debug sensors
│   ├── http-ota.yaml           # HTTP firmware updates (factory only)
│   └── secrets.yaml            # Include directive for ../secrets.yaml
│
├── devices/                     # Hardware definitions (one per device model)
│   └── wyze/
│       └── outdoor-plug.yaml   # GPIO pins, power monitoring, buttons, LEDs
│
├── firmware/                    # Build configurations (base + factory pattern)
│   ├── wyze-outdoor-plug.yaml          # Base config (adoptable)
│   └── wyze-outdoor-plug.factory.yaml  # Factory config (productized)
│
├── examples/                    # User-facing examples
│   └── wyze-outdoor-plug.yaml  # Template users copy and customize
│
├── .github/workflows/
│   ├── validate.yaml           # CI: validates all configs
│   └── build-firmware.yaml     # Release: builds *.factory.yaml, deploys to GitHub Pages
│
├── secrets.yaml.example        # Template for user secrets
├── PROJECT.md                  # THIS DOCUMENT - vision and standards
└── README.md                   # User-facing quick start
```

### Base vs Factory Pattern

| Config Type | Purpose | HTTP OTA | dashboard_import | Built by CI |
|-------------|---------|----------|------------------|-------------|
| **Base** (`device.yaml`) | Adoptable config | ❌ No | ❌ No | ❌ No |
| **Factory** (`device.factory.yaml`) | Productized firmware | ✅ Yes | ✅ Yes (points to base) | ✅ Yes |

**Base configs** contain all device functionality (hardware, sensors, common packages) but NO productized features.

**Factory configs** extend base with:
- `http-ota.yaml` package for auto-updates
- `dashboard_import` pointing to BASE config (not factory!)
- `esp32_improv` or `improv_serial` for WiFi provisioning
- `esphome.project` metadata for version tracking

When users **adopt** a device, Dashboard imports the BASE config - giving them full functionality without HTTP OTA. This prevents conflicts between local management and central updates.

### Package Layers

| Layer | File | Purpose |
|-------|------|---------|
| 1 | `common/base.yaml` | WiFi, API, OTA, logger, time, mDNS - universal services |
| 2 | `common/esp*-platform.yaml` | Platform framework config (ESP32/ESP8266) |
| 3 | `common/diagnostics.yaml` | WiFi signal, uptime, debug sensors |
| 4 | `common/http-ota.yaml` | HTTP OTA updates (factory configs only) |
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

## Device Provisioning & Adoption Flow

Devices use the [Improv WiFi](https://www.improv-wifi.com/) standard for first-time setup:

### Productized Flow (Auto-Updates)
```
1. User flashes factory firmware via web installer or USB
2. Improv prompts for WiFi credentials
3. Device connects to network and starts checking for HTTP OTA updates
4. User does NOT adopt in Dashboard - device just works
5. Device receives automatic updates when community improves configs
```

### Adoption Flow (Full Control)
```
1. User flashes factory firmware via web installer or USB
2. Improv prompts for WiFi credentials
3. Device connects to network
4. ESPHome Dashboard discovers device (via mDNS + project info)
5. User clicks "Adopt" in Dashboard
6. Dashboard imports BASE config (not factory!) with:
   - All device functionality (no HTTP OTA)
   - UNIQUE API encryption key (per device!)
   - Customized device name
7. User manages device locally - no central auto-updates
```

### Key Components

| Component | Purpose | In Base | In Factory |
|-----------|---------|---------|------------|
| `captive_portal` | Fallback AP with web config | ✅ | ✅ |
| `improv_serial` | USB/Serial WiFi provisioning | ❌ | ✅ |
| `esp32_improv` | BLE WiFi provisioning (ESP32) | ❌ | ✅ |
| `dashboard_import` | Enables Dashboard adoption | ❌ | ✅ |
| `http-ota.yaml` | HTTP OTA from GitHub | ❌ | ✅ |

### Security Model

- **No credentials compiled into firmware** - WiFi provisioned at runtime via Improv
- **Adopted devices get unique API keys** - Generated by Dashboard during adoption
- **Productized devices have no encryption** - Trade-off for central auto-updates
- **Credentials stored in NVS** - Persist across OTA updates

---

## Adding New Devices (Phase 2+)

1. **Create hardware file**: `devices/brand/model.yaml`
   - Board type
   - GPIO mappings
   - Hardware-specific sensors
   - Set `firmware_name` substitution

2. **Create base config**: `firmware/brand-model.yaml`
   - Import common packages (base, platform, diagnostics)
   - Import hardware file
   - NO http-ota, NO dashboard_import, NO improv

3. **Create factory config**: `firmware/brand-model.factory.yaml`
   - Import base config as package
   - Import http-ota.yaml
   - Add `dashboard_import` pointing to BASE config
   - Add `esp32_improv` (ESP32) or `improv_serial` (ESP8266)
   - Add `esphome.project` metadata

4. **Create example**: `examples/brand-model.yaml`

5. **Update CI**: Add factory config to build-firmware.yaml matrix

6. **Test on real hardware**: Validate, compile, flash, verify HTTP OTA works

---

## Quality Standards

### Every Device MUST:
- Have a base config (`firmware/device.yaml`) - adoptable, no HTTP OTA
- Have a factory config (`firmware/device.factory.yaml`) - extends base with HTTP OTA
- Have an examples/ template
- Factory config must be in build-firmware.yaml matrix
- Be tested on real hardware

### Code MUST:
- Follow DRY - no duplication between device files
- Use substitutions for calibration values
- Factory configs must include improv for WiFi setup
- Set firmware_name matching the manifest filename
- dashboard_import must point to BASE config (not factory!)

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
