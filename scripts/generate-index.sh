#!/usr/bin/env bash
# Generate the GitHub Pages landing page from deployed firmware manifests.
#
# The Pages root previously had no index, so the URL published in the README
# returned 404. This builds a small page listing every device the release
# shipped, with its OTA manifest, binary and checksum.
#
# Usage: scripts/generate-index.sh <dir>
#   <dir> holds *-manifest.json, *.bin, *.md5 and optionally build-info.json.
#   Writes <dir>/index.html.
set -euo pipefail

DIR="${1:?usage: generate-index.sh <dir>}"
INFO="${DIR}/build-info.json"

if [ -f "${INFO}" ]; then
  VERSION=$(jq -r '.version // "unknown"' "${INFO}")
  ESPHOME_VERSION=$(jq -r '.esphome_version // "unknown"' "${INFO}")
  BUILT_AT=$(jq -r '.built_at // ""' "${INFO}")
else
  VERSION="unknown"; ESPHOME_VERSION="unknown"; BUILT_AT=""
fi

esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

{
  cat <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ESPHome Device Library - Firmware</title>
<style>
  :root {
    --bg: #fbfbfa; --fg: #1a1a19; --muted: #6b6b66;
    --line: #e2e2dd; --card: #ffffff; --accent: #1f6f5c;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #16161a; --fg: #e8e8e4; --muted: #9a9a93;
      --line: #2c2c31; --card: #1d1d22; --accent: #5fbfa4;
    }
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; padding: 2.5rem 1.25rem; background: var(--bg); color: var(--fg);
    font: 16px/1.6 ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  }
  main { max-width: 52rem; margin: 0 auto; }
  h1 { font-size: 1.6rem; margin: 0 0 .35rem; letter-spacing: -.01em; }
  .sub { color: var(--muted); margin: 0 0 2rem; }
  .meta { display: flex; flex-wrap: wrap; gap: .5rem 1.5rem; margin: 0 0 2rem;
          padding: .85rem 1rem; background: var(--card);
          border: 1px solid var(--line); border-radius: 10px; font-size: .9rem; }
  .meta b { font-weight: 600; }
  .wrap { overflow-x: auto; }
  table { border-collapse: collapse; width: 100%; font-size: .93rem; }
  th, td { text-align: left; padding: .7rem .8rem; border-bottom: 1px solid var(--line); }
  th { font-size: .78rem; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); }
  td.dev { font-weight: 600; }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: .85em; }
  a { color: var(--accent); }
  footer { margin-top: 2.5rem; padding-top: 1.25rem; border-top: 1px solid var(--line);
           color: var(--muted); font-size: .87rem; }
</style>
</head>
<body>
<main>
<h1>ESPHome Device Library</h1>
<p class="sub">Pre-built firmware and OTA update manifests.</p>
HTML

  printf '<div class="meta"><span><b>Release:</b> %s</span>' "$(printf '%s' "${VERSION}" | esc)"
  printf '<span><b>ESPHome:</b> %s</span>' "$(printf '%s' "${ESPHOME_VERSION}" | esc)"
  [ -n "${BUILT_AT}" ] && printf '<span><b>Built:</b> %s</span>' "$(printf '%s' "${BUILT_AT}" | esc)"
  printf '</div>\n'

  echo '<div class="wrap"><table>'
  echo '<thead><tr><th>Device</th><th>Chip</th><th>Version</th><th>Downloads</th></tr></thead><tbody>'
  for m in "${DIR}"/*-manifest.json; do
    [ -e "${m}" ] || continue
    name=$(jq -r '.name' "${m}")
    ver=$(jq -r '.version' "${m}")
    chip=$(jq -r '.builds[0].chipFamily // "?"' "${m}")
    bin=$(jq -r '.builds[0].ota.path' "${m}")
    printf '<tr><td class="dev">%s</td><td>%s</td><td><code>%s</code></td>' \
      "$(printf '%s' "${name}" | esc)" "$(printf '%s' "${chip}" | esc)" \
      "$(printf '%s' "${ver}" | esc)"
    printf '<td><a href="%s">manifest</a> &middot; <a href="%s">firmware</a>' \
      "$(basename "${m}")" "$(printf '%s' "${bin}" | esc)"
    [ -f "${DIR}/${name}.md5" ] && printf ' &middot; <a href="%s.md5">md5</a>' \
      "$(printf '%s' "${name}" | esc)"
    printf '</td></tr>\n'
  done
  echo '</tbody></table></div>'

  cat <<'HTML'
<footer>
Devices running this firmware poll their manifest every 6 hours and surface updates in
Home Assistant. Manifest URLs are stable: <code>&lt;device-name&gt;-manifest.json</code>
alongside this page.
<br><br>
Source and documentation:
<a href="https://github.com/heytcass/esphome-device-library">github.com/heytcass/esphome-device-library</a>
</footer>
</main>
</body>
</html>
HTML
} > "${DIR}/index.html"

echo "Wrote ${DIR}/index.html ($(wc -c < "${DIR}/index.html") bytes)"
