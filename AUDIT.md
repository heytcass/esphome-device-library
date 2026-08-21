# Repository Audit — August 2026

An end-to-end review of esphome-device-library: what's broken, what's drifted, how the
ESPHome ecosystem has moved underneath it since January, and whether the project still has a
reason to exist (spoiler: yes, but with a sharper scope). Every claim below was verified
against the current toolchain — all six factory configs were run through ESPHome **2026.6.5**
(current stable at time of audit), yamllint was run with the repo's own config, and the CI
history on `main` was pulled from GitHub Actions.

---

## TL;DR

1. **The repo has fallen into the exact trap it was created to fight.** The README promises
   "living, auto-updating configs," but the last firmware release is v2.4.1 from
   January 13, 2026. Devices in the field have been running a seven-month-old build, and
   `main` has had two of three CI workflows red since January/April.
2. **3 of 6 devices no longer validate on current ESPHome.** Both Sendspin display devices
   crash config validation outright, and the Sonocotta Louder fails schema validation. The
   three "boring" devices (Wyze, Sonoff S31, Seeed reTerminal) all still pass.
3. **The ecosystem caught up with the custom stuff.** Nearly every external component this
   repo pins (`sendspin`, `mixer`, `resampler`, `media_source`, `speaker_source`) has since
   been merged into ESPHome core. The pinned copies are now stale forks that break against
   modern ESPHome — deleting them is both the fix and a large simplification.
4. **The build pipeline is about to break a second time.** ESPHome 2026.7 makes the native
   ESP-IDF toolchain the default for ESP32; the workflow's hardcoded
   `find … .pioenvs/*/firmware.bin` will stop finding binaries when CI picks that version up.
5. **Yes, there is a point** — but the niche is *maintained, auto-updating firmware for
   off-the-shelf devices*, not replacing devices.esphome.io (which is now actively maintained
   under the esphome GitHub org). The sustainable path for a time-limited maintainer is
   automation: scheduled rebuild releases, CI canaries against ESPHome dev, auto-discovered
   build matrices, and per-device community ownership.

---

## 1. Verified current state

### CI status on `main` (as of last push, April 19, 2026)

| Workflow | Status | Cause |
|----------|--------|-------|
| Validate ESPHome Configs | ✅ passing | — (but see §4.2 for why this is misleading) |
| Build Firmware | ❌ failing since Apr 19 | `sendspin-tab5.factory.yaml` job fails |
| YAML Lint | ❌ failing since Jan 18 | 5 over-long lines (see below) |

The lint failure is trivial: four lines in `.github/workflows/claude.yml` (17, 19–21) and one
in `devices/seeed/reterminal-e1002.yaml` (17) exceed the configured 120-char limit. It's been
red for seven months, which matters less for the five lines and more for what it signals to a
potential contributor: red badges on main read as "unmaintained."

### Validation against ESPHome 2026.6.5 (current stable)

| Config | Result | Detail |
|--------|--------|--------|
| `wyze-outdoor-plug.factory` | ✅ passes | Only benign strapping-pin warnings (GPIO15/GPIO5 — hardware reality) |
| `sonoff-s31.factory` | ✅ passes | Clean |
| `seeed-reterminal-e1002.factory` | ✅ passes | Clean |
| `sendspin-tab5.factory` | ❌ **crashes** | Pinned `sendspin` external component uses `cv.only_with_esp_idf`, removed from ESPHome after the Jan 2026 `USE_ESP_IDF` deprecation |
| `sendspin-eink-display.factory` | ❌ **crashes** | Same root cause |
| `sonocotta-louder-esp32s3.factory` | ❌ fails | `media_source.file` schema rejected — the seven pinned PR branches have drifted from what was merged |

The failure mode is exactly the "stale pinned dependency" rot the project's own PROJECT.md
warns about. The pins reference mutable refs — `github://pr#12253` etc. resolve to PR *head*
branches that authors force-push, and `refresh: 0s` means whatever gets cloned first wins.
These were never reproducible builds.

### The auto-update promise

The cornerstone feature — devices checking
`https://heytcass.github.io/esphome-device-library/<name>-manifest.json` every 6 hours — only
delivers value when releases actually happen. Releases are fully manual (a human must publish
a GitHub Release), and none has happened since January. A "living config" system with no
release cadence is a static config dump with extra steps. This is the single highest-leverage
thing to fix, and it's an automation problem, not an effort problem (see §5).

---

## 2. What's genuinely good (keep all of this)

- **The base/factory split is the right architecture.** It mirrors the Home Assistant Voice
  PE pattern, `dashboard_import` correctly points at the base config, and the reasoning is
  documented. This is better than most community firmware repos.
- **The package layering is clean.** `common/base.yaml` → platform → diagnostics → device
  hardware is easy to follow, and device files genuinely contain mostly hardware.
- **PROJECT.md is unusually honest.** North-star principles, explicit anti-patterns, phase
  gates with exit criteria. Most solo projects don't have this. It needs a refresh, not a
  rewrite.
- **Provisioning story is coherent.** No compiled-in WiFi credentials, captive portal +
  Improv, credentials in NVS across OTA. `min_auth_mode: WPA2` shows the repo was tracking
  upstream changes when it was active.
- **The three "boring" devices still validate cleanly** after 7 months untouched — evidence
  that the core thesis (simple retail hardware + shared packages) is durable. What rotted was
  the experimental layer.

---

## 3. Scope drift — the thing you already suspected

The repo's stated mission: configs for **off-the-shelf products you bought** and want in
ESPHome. Measured against that:

| Device | On-mission? |
|--------|-------------|
| Wyze Outdoor Plug | ✅ Core thesis — retail device, liberated |
| Sonoff S31 | ✅ Core thesis |
| Seeed reTerminal E1002 | ✅ Retail hardware (dev-product, but off-the-shelf) |
| Sonocotta Louder ESP32-S3 | ⚠️ Retail-ish hardware, but built on 7 unmerged-PR pins — violated "WORKING > FEATURES" from day one |
| Sendspin Tab5 | ❌ An *application* (media controller UI) that happens to run on M5Stack hardware |
| Sendspin E-Ink Display | ❌ Same — application firmware, not device support |

Two structural tells confirm the drift:

1. `devices/` is organized brand/model (`wyze/`, `sonoff/`, `seeed/`) — but `sendspin` is not
   a brand, it's a protocol. The Tab5 is M5Stack hardware. The taxonomy broke because the
   content stopped being device support.
2. `common/sendspin/` (5 role files: base/player/controller/metadata/artwork) is an
   application framework living in the shared-packages tier. It's well-built! But it's a
   different project — "Sendspin display firmware" — wearing this repo as a host.

The two Sendspin devices are also precisely the two that crashed validation. Application
firmware chasing an experimental protocol needs weekly attention; device configs for a smart
plug need yearly attention. Mixing the two cadences in one repo means the fast-rotting half
takes the whole repo's badges (and credibility) down with it.

**Recommendation:** split them. Keep this repo as the device library (Wyze, Sonoff, Seeed,
and — once it builds on core components — Sonocotta). Move the Sendspin application firmware
(the role packages + tab5 + eink-display) to its own repo, e.g. `sendspin-display-firmware`,
where it can pin whatever it needs and rot or thrive on its own schedule. Since Sendspin is
now a core ESPHome component (see §4.1), that repo also gets much simpler.

---

## 4. The ecosystem moved — modernization findings

### 4.1 The pinned external components are now in ESPHome core

Verified against the 2026.6.5 component tree: `sendspin` (media_player, media_source, sensor,
text_sensor), `mixer`, `resampler`, `media_source`, `speaker_source`, and `runtime_image` all
ship in core now. The Sendspin protocol went stable via Music Assistant 2.7 and has an
official docs page.

- `common/sendspin/base.yaml` pins three git refs, including two raw commits of the esphome
  repo — all deletable in favor of core components.
- `devices/sonocotta/louder-esp32s3.yaml` pins seven PR heads — most deletable; the TAS5805M
  DAC driver (`mrtoy-me/esphome-tas5805m`) remains legitimately external, and should be
  pinned to a tag/commit rather than the mutable `@beta`.
- One caveat: the sendspin **artwork** platform (`generic_image`) is *not* yet in core (the
  upstream artwork PR is still in flight), so the eink/tab5 display configs would keep
  exactly one pinned component until it lands — or that dependency moves out with the split.

### 4.2 CI validates the wrong thing

`validate.yaml` validates `examples/*.yaml` — which fetch packages from
`github://…@main`, not from the PR checkout. A PR that breaks `common/base.yaml` passes
validation (it tests yesterday's main) and only fails in the slower compile job, if the path
filter even triggers it. Validation should target `firmware/*.factory.yaml` (local includes,
tests the actual diff) with examples as a secondary remote-syntax check.

Additionally, both workflow matrices are hand-maintained lists — CONTRIBUTING.md step 4 tells
contributors to edit two workflow files per device. A glob-based auto-discovery step
(`ls firmware/*.factory.yaml`) removes that whole class of drift and shrinks the contribution
checklist.

### 4.3 The build pipeline is about to break again (2026.7)

ESPHome 2026.7 switches ESP32 builds from PlatformIO to the native ESP-IDF toolchain by
default. Consequences for `build-firmware.yaml`:

- `find . -path "*/.pioenvs/*/firmware.bin"` finds nothing — output moves to
  `build/firmware.elf` with `firmware.factory.bin` / `firmware.ota.bin` siblings.
- The factory/OTA distinction becomes explicit. The current pipeline ships one `.bin` for
  both first-flash and OTA; the modern layout wants the **factory** image for web-installer
  flashing and the **ota** image in the update manifest.

Rather than patching the hand-rolled pipeline, adopt the official tooling this repo's whole
pattern is borrowed from: **`esphome/build-action`** (used by `esphome/firmware` and the
`esphome/esphome-project-template`). It compiles, produces correctly-split binaries and an
esp-web-tools manifest, and is maintained by the ESPHome team — deleting roughly 100 lines of
bespoke workflow. Bonus it unlocks for free: a **GitHub Pages web installer** ("plug in your
device, click flash in Chrome"), which the README currently can't offer and which is the
single biggest onboarding improvement available for non-technical users.

### 4.4 Dead code and stale references

- **The entire secrets apparatus is unused.** Nothing in any config references `!secret`;
  `common/secrets.yaml` is included by nothing; both CI workflows write a `secrets.yaml` that
  nothing reads. `secrets.yaml.example` documents five secrets, none consumed (the AP
  password is hardcoded as `esphome123` in `base.yaml`). Delete all of it, or wire it up —
  currently it's misleading scaffolding from a pre-Improv design.
- `flake.nix` shellHook points at `docs/DEVELOPMENT.md` and
  `examples/local-development/wyzeoutdoor1.yaml` — neither exists.
- PROJECT.md phase tracker says Phase 3 is "CURRENT" but describes reality from January;
  the "Session Checklist for Claude Agents" belongs in a root `CLAUDE.md` (which doesn't
  exist) where agents actually look for it.
- `.github/workflows/claude.yml` uses the long-deprecated `@beta` action tag with direct API
  key auth, and is itself the source of 4 of the 5 lint failures.
- README's Quick Start block duplicates `examples/wyze-outdoor-plug.yaml` inline — two copies
  to keep in sync; link the file instead.

### 4.5 Security posture (document it or fix it)

None of these are emergencies for a hobby fleet, but a community project should either fix or
explicitly own each:

- **Productized firmware has no API encryption** (PROJECT.md documents this as a trade-off).
  Fine, but adoption via the Device Builder dashboard generates per-device keys — worth
  restating in the README's security notes now that HA nags about unencrypted ESPHome nodes.
- **ESP8266 devices fetch OTA manifests with `verify_ssl: false`** and the MD5 in the
  manifest is integrity, not authenticity — an on-path attacker could serve arbitrary
  firmware to an S31. Worth a documented threat-model note at minimum; longer-term, ESP8266
  fingerprint pinning or accepting the limitation loudly.
- **`esphome123` AP password is fleet-wide and public.** Acceptable for a fallback AP that
  only appears when WiFi is lost; say so explicitly.

---

## 5. Is there a point? — positioning and sustainability

### The honest competitive map (August 2026)

- **devices.esphome.io** — now lives under the esphome GitHub org and merges community PRs
  actively. It is a *documentation database*: copy-paste YAML pages, no CI validation, no
  builds, no OTA, and configs still rot on the page exactly as you described. "Replacing" it
  is not a realistic goal for a solo repo — but it isn't the same product either.
- **esphome/firmware + firmware.esphome.io** — official pre-built firmware, but only for
  ESPHome's own projects (Bluetooth proxy, Voice PE, etc.). They will never cover Wyze plugs.
- **Vendor firmware (Athom, etc.)** — a few vendors ship ESPHome-ready hardware with their
  own factory firmware; nobody does this for *liberated* retail devices.

**The gap this repo actually fills:** *CI-validated, pre-built, auto-updating ESPHome
firmware for retail devices whose vendors will never provide it.* That's a real niche nobody
occupies — devices.esphome.io gives you a YAML page from 2019; this repo gives you a web
installer and a firmware-update entity in Home Assistant. The realistic relationship with
devices.esphome.io is **complement + funnel, not replacement**: contribute/refresh the device
pages upstream and have them link here for the "maintained, auto-updating" option. If the
model proves out at 10–15 devices with a few external maintainers, *then* a conversation with
the ESPHome team about deeper integration is worth having — from a position of a working
system, not a proposal.

### Sustainability for a maintainer with a dad-schedule

The January–August gap proves the current design needs a human in the loop at exactly the
points where you don't have slack. Every recommendation below removes a human dependency:

1. **Scheduled rebuild releases (the big one).** A monthly cron workflow that rebuilds all
   factory firmware with current ESPHome, and on success auto-publishes a CalVer release
   (`2026.8.0`). Devices then receive fresh ESPHome cores — security fixes included — with
   zero maintainer action. This *is* the product promise, automated. A failed rebuild files
   an issue instead of releasing (that's your to-do list, generated for you).
2. **Canary workflow against ESPHome dev/beta** (weekly, allowed to fail): you learn about
   breakage like `only_with_esp_idf` months before stable ships it, via a filed issue instead
   of a red main.
3. **Auto-discovered matrices** (§4.2): contributors touch only their device's files.
4. **Renovate/Dependabot** for action pins and the flake lock.
5. **Community structure:** issue forms ("New device request" / "Calibration improvement"),
   a PR template mirroring the CONTRIBUTING checklist, and a per-device MAINTAINERS file —
   the scalable model is you maintaining the *system* while each device has an owner who has
   the hardware. CONTRIBUTING already requires real-hardware testing; per-device ownership is
   the natural extension.
6. **Scope discipline as a sustainability feature:** the §3 split isn't aesthetic — it
   removes the fast-rotting half of the maintenance surface from the repo you're asking the
   community to trust.

---

## 6. Recommended plan

**P0 — Stop the bleeding (small, do first)**
1. Fix the 5 yamllint lines → YAML Lint green.
2. Migrate `common/sendspin/*` and Sonocotta to core components (drop every
   merged-into-core pin; pin TAS5805M to a commit; keep only the artwork pin if staying).
   → all six configs validate on 2026.6.x, Build Firmware green.
3. Fix `build-firmware.yaml` binary discovery for the native toolchain (or jump straight to
   `esphome/build-action`).
4. Cut a release so fielded devices finally get a 2026-current build.

**P1 — Automate the promise**
5. Monthly scheduled rebuild-and-release workflow + weekly dev-branch canary.
6. Point `validate.yaml` at `firmware/*.factory.yaml` with globbed matrices.
7. Adopt `esphome/build-action` fully + publish an esp-web-tools installer page on Pages.

**P2 — Refocus and tidy**
8. Split Sendspin application firmware into its own repo; re-home Tab5 under `devices/m5stack/`.
9. Delete the dead secrets apparatus; fix flake shellHook; add `CLAUDE.md`; refresh
   PROJECT.md phases and README (link examples instead of inlining; add security notes).
10. Replace `claude.yml` with the current claude-code-action release.

**P3 — Open the doors**
11. Issue forms, PR template, per-device MAINTAINERS.
12. Refresh the corresponding devices.esphome.io pages upstream with links here; announce on
    the HA community forum once badges are green and the installer page exists.

**Decisions only you can make:** whether Sendspin splits out or stays (the audit recommends
splitting); whether Sonocotta is worth migrating now or parking until you can retest on
hardware (its config can't be verified without the device); and the security stance in §4.5.
