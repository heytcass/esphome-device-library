# Maintainers

This library ships firmware to other people's devices and rebuilds every device monthly
against the current ESPHome release. That only stays trustworthy if somebody with each
device can confirm it still works.

## Devices

| Device | Maintainer | Status |
|--------|------------|--------|
| [Wyze Outdoor Plug](devices/wyze/outdoor-plug.yaml) | [@heytcass](https://github.com/heytcass) | Maintained — co-maintainer welcome |
| [Sonoff S31](devices/sonoff/s31.yaml) | [@heytcass](https://github.com/heytcass) | Maintained — co-maintainer welcome |
| [Seeed reTerminal E1002](devices/seeed/reterminal-e1002.yaml) | [@heytcass](https://github.com/heytcass) | Maintained — co-maintainer welcome |

Project and CI maintainer: [@heytcass](https://github.com/heytcass).

## What a device maintainer does

Not much, most months — the point of the automation is that nothing is needed when
nothing changes.

- **Answer questions** about your device on issues, when you can.
- **Sanity-check releases that change your device.** Most monthly releases only pick up a
  new ESPHome core; you do not need to test every one. Test when a release changes your
  device's config, or when CI opens an `automated-rebuild` issue naming it.
- **Review PRs touching your device**, particularly calibration changes — you are the
  person who can say whether a number is plausible.

You do not need commit access, and you are not on the hook for the CI, the release
pipeline, or other people's devices.

## Becoming one

Open a [new device issue](https://github.com/heytcass/esphome-device-library/issues/new?template=new-device.yml) for hardware not yet
here, or comment on an existing device's issue to co-maintain it. The only real
requirement is owning the device and being willing to flash it occasionally.

## When a device goes unmaintained

Devices are removed rather than left to rot silently — a config that no longer builds is
worse than no config, because it looks supported. If a device has no maintainer and its
build breaks:

1. CI opens an `automated-rebuild` issue naming the failing device.
2. If nobody can fix or test it within roughly two release cycles, it is removed from the
   build matrix and the README, and the issue records why.
3. Its files stay in git history and can be restored the moment someone with the hardware
   turns up.

This happened in August 2026 to the Sendspin and Sonocotta devices, which had been built
on external components pinned to moving refs that drifted out from under them. See
[AUDIT.md](AUDIT.md).

## A note on external components

Device configs should build from ESPHome core. Pinning `github://pr#1234` or a branch is
how this library previously accumulated devices that stopped building: PR branches get
force-pushed and rebased, so the "pinned" config silently changes underneath you. If a
device genuinely needs an out-of-tree component, pin it to an immutable commit or tag and
say in a comment what would let it move back to core.
