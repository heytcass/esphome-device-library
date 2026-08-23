## What this changes

<!-- One or two sentences. For a new device, name the brand and model. -->

## Hardware testing

<!--
Required for anything touching common/, devices/ or firmware/ — this repo ships
firmware to other people's devices, and CI can only prove a config compiles, not
that it works. Say what you flashed it to and what you checked. If you did not
test on hardware, say so plainly; it is better than an untested assumption.
-->

- Device tested on:
- Verified working:

## Checklist

<!-- Delete rows that do not apply. Docs- or CI-only changes need almost none of this. -->

- [ ] Tested on real hardware (see above)
- [ ] `esphome config firmware/<device>.factory.yaml` passes against current ESPHome
- [ ] `yamllint --strict .` passes

For a new device:

- [ ] Hardware definition in `devices/<brand>/<model>.yaml`, GPIO and calibration only
- [ ] Base config `firmware/<brand>-<model>.yaml` — adoptable, no HTTP OTA
- [ ] Factory config `firmware/<brand>-<model>.factory.yaml` — adds HTTP OTA, Improv,
      and `dashboard_import` pointing at the **base** config
- [ ] Example in `examples/<brand>-<model>.yaml`
- [ ] Added to the `validate.yaml` matrix (the example) and the `build-firmware.yaml`
      matrix (the factory config, with its `chip_family`)
- [ ] Added to the device table in `README.md` and to `MAINTAINERS.md`
- [ ] No external components pinned to a moving ref — see MAINTAINERS.md on why

## Anything reviewers should know

<!-- Trade-offs, things you were unsure about, things you deliberately left out. -->
