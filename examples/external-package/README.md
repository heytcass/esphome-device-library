# External Package Examples

These examples show how to use the ESPHome Device Library as an external package reference.

## Usage

Simply copy one of these example files and customize the substitutions:

```yaml
substitutions:
  device_name: my-device-name
  friendly_name: "My Device"
```

The configuration will automatically pull the latest hardware definitions from GitHub.

## Advantages

- ✅ Always get latest updates
- ✅ Minimal configuration file
- ✅ Centralized device definitions
- ✅ Easy to maintain

## Version Pinning

For production use, pin to a specific version:

```yaml
packages:
  base:
    url: https://github.com/heytcass/esphome-device-library
    ref: v1.0.0  # Pin to specific version
    files: [...]
```

## Refresh Rate

Control how often ESPHome checks for updates:

```yaml
refresh: 1d   # Daily (recommended)
refresh: 1h   # Hourly (for active development)
refresh: never  # Manual updates only
```
