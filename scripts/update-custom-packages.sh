#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname "$0")/.." && pwd)"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

for tool in curl jq git nix-prefetch-url nix python3; do
  require "$tool"
done

to_sri() {
  nix hash convert --hash-algo sha256 --from nix32 "$1"
}

prefetch_url() {
  local url="$1"
  local raw
  raw="$(nix-prefetch-url "$url")"
  to_sri "$raw"
}

prefetch_unpacked() {
  local url="$1"
  local raw
  raw="$(nix-prefetch-url --unpack "$url")"
  to_sri "$raw"
}

latest_release_tag() {
  local repo="$1"
  local tag
  tag="$(curl -sL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name')"
  if [[ -z "$tag" || "$tag" == "null" ]]; then
    echo "Failed to fetch latest release tag for ${repo}" >&2
    exit 1
  fi
  printf '%s' "$tag"
}

impactor_tag="$(latest_release_tag "khcrysalis/Impactor")"
impactor_version="${impactor_tag#v}"
impactor_url="https://github.com/khcrysalis/Impactor/releases/download/${impactor_tag}/Impactor-linux-x86_64.appimage"
impactor_hash="$(prefetch_url "$impactor_url")"
plumesign_url="https://github.com/khcrysalis/Impactor/releases/download/${impactor_tag}/plumesign-linux-x86_64"
plumesign_hash="$(prefetch_url "$plumesign_url")"

grepai_tag="$(latest_release_tag "yoanbernabeu/grepai")"
grepai_version="${grepai_tag#v}"
grepai_url="https://github.com/yoanbernabeu/grepai/releases/download/${grepai_tag}/grepai_${grepai_version}_linux_amd64.tar.gz"
grepai_hash="$(prefetch_url "$grepai_url")"

yazi_rev="$(git ls-remote https://github.com/yazi-rs/plugins.git HEAD | awk '{print $1}')"
yazi_tarball="https://github.com/yazi-rs/plugins/archive/${yazi_rev}.tar.gz"
yazi_hash="$(prefetch_unpacked "$yazi_tarball")"

modernx_rev="$(git ls-remote https://github.com/cyl0/ModernX.git HEAD | awk '{print $1}')"
modernx_tarball="https://github.com/cyl0/ModernX/archive/${modernx_rev}.tar.gz"
modernx_hash="$(prefetch_unpacked "$modernx_tarball")"

agent_browser_skill_url="https://raw.githubusercontent.com/vercel-labs/agent-browser/main/skills/agent-browser/SKILL.md"
agent_browser_skill_hash="$(prefetch_url "$agent_browser_skill_url")"
grepai_skill_url="https://raw.githubusercontent.com/yoanbernabeu/grepai/main/.claude/skills/grepai/SKILL.md"
grepai_skill_hash="$(prefetch_url "$grepai_skill_url")"

scyrox_favicon_url="https://www.scyrox.net/favicon.ico"
scyrox_favicon_hash="$(prefetch_url "$scyrox_favicon_url")"
xsyd_favicon_url="https://v2.xsyd.top/favicon.ico"
xsyd_favicon_hash="$(prefetch_url "$xsyd_favicon_url")"

IMPACTOR_VERSION="$impactor_version" \
IMPACTOR_URL="$impactor_url" \
IMPACTOR_HASH="$impactor_hash" \
PLUMESIGN_VERSION="$impactor_version" \
PLUMESIGN_URL="$plumesign_url" \
PLUMESIGN_HASH="$plumesign_hash" \
GREPAI_VERSION="$grepai_version" \
GREPAI_URL="$grepai_url" \
GREPAI_HASH="$grepai_hash" \
python3 - "$repo_root/home-manager/packages.nix" <<'PY'
import os
import re
import sys

path = sys.argv[1]
data = open(path, "r", encoding="utf-8").read()

def replace(pattern, repl):
    global data
    updated, count = re.subn(pattern, repl, data, flags=re.M)
    if count != 1:
        raise SystemExit(f"Pattern matched {count} times: {pattern}")
    data = updated

replace(
    r'(pname = "impactor";\n\s+version = ")[^"]+(";)',
    r'\1' + os.environ["IMPACTOR_VERSION"] + r'\2',
)
replace(
    r'url = "https://github.com/khcrysalis/Impactor/releases/download/[^"]+/Impactor-linux-x86_64\.appimage";\n\s+hash = "sha256-[^"]+";',
    f'url = "{os.environ["IMPACTOR_URL"]}";\n    hash = "{os.environ["IMPACTOR_HASH"]}";',
)
replace(
    r'(pname = "plumesign";\n\s+version = ")[^"]+(";)',
    r'\1' + os.environ["PLUMESIGN_VERSION"] + r'\2',
)
replace(
    r'url = "https://github.com/khcrysalis/Impactor/releases/download/[^"]+/plumesign-linux-x86_64";\n\s+hash = "sha256-[^"]+";',
    f'url = "{os.environ["PLUMESIGN_URL"]}";\n      hash = "{os.environ["PLUMESIGN_HASH"]}";',
)
replace(
    r'(pname = "grepai";\n\s+version = ")[^"]+(";)',
    r'\1' + os.environ["GREPAI_VERSION"] + r'\2',
)
replace(
    r'url = "https://github.com/yoanbernabeu/grepai/releases/download/v[^"]+/grepai_[^"]+_linux_amd64\.tar\.gz";\n\s+hash = "sha256-[^"]+";',
    f'url = "{os.environ["GREPAI_URL"]}";\n      hash = "{os.environ["GREPAI_HASH"]}";',
)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(data)
PY

YAZI_REV="$yazi_rev" \
YAZI_HASH="$yazi_hash" \
python3 - "$repo_root/home-manager/yazi.nix" <<'PY'
import os
import re
import sys

path = sys.argv[1]
data = open(path, "r", encoding="utf-8").read()

pattern = r'(rev = ")[^"]+(";\n\s+hash = ")[^"]+(";)' 
replacement = f'rev = "{os.environ["YAZI_REV"]}";\n    hash = "{os.environ["YAZI_HASH"]}";'

updated, count = re.subn(pattern, replacement, data, flags=re.M)
if count != 1:
    raise SystemExit(f"Pattern matched {count} times: {pattern}")

with open(path, "w", encoding="utf-8") as fh:
    fh.write(updated)
PY

MODERNX_REV="$modernx_rev" \
MODERNX_HASH="$modernx_hash" \
python3 - "$repo_root/home-manager/mpv.nix" <<'PY'
import os
import re
import sys

path = sys.argv[1]
data = open(path, "r", encoding="utf-8").read()

pattern = r'(rev = ")[^"]+(";\n\s+hash = ")[^"]+(";)' 
replacement = f'rev = "{os.environ["MODERNX_REV"]}";\n    hash = "{os.environ["MODERNX_HASH"]}";'

updated, count = re.subn(pattern, replacement, data, flags=re.M)
if count != 1:
    raise SystemExit(f"Pattern matched {count} times: {pattern}")

with open(path, "w", encoding="utf-8") as fh:
    fh.write(updated)
PY

AGENT_BROWSER_SKILL_URL="$agent_browser_skill_url" \
AGENT_BROWSER_SKILL_HASH="$agent_browser_skill_hash" \
GREPAI_SKILL_URL="$grepai_skill_url" \
GREPAI_SKILL_HASH="$grepai_skill_hash" \
python3 - "$repo_root/home-manager/opencode.nix" <<'PY'
import os
import re
import sys

path = sys.argv[1]
data = open(path, "r", encoding="utf-8").read()

def replace(url, new_url, new_hash):
    global data
    pattern = rf'url = "{re.escape(url)}";\n\s+hash = "sha256-[^"]+";'
    replacement = f'url = "{new_url}";\n    hash = "{new_hash}";'
    updated, count = re.subn(pattern, replacement, data, flags=re.M)
    if count != 1:
        raise SystemExit(f"Pattern matched {count} times: {pattern}")
    data = updated

replace(
    os.environ["AGENT_BROWSER_SKILL_URL"],
    os.environ["AGENT_BROWSER_SKILL_URL"],
    os.environ["AGENT_BROWSER_SKILL_HASH"],
)
replace(
    os.environ["GREPAI_SKILL_URL"],
    os.environ["GREPAI_SKILL_URL"],
    os.environ["GREPAI_SKILL_HASH"],
)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(data)
PY

SCYROX_FAVICON_URL="$scyrox_favicon_url" \
SCYROX_FAVICON_HASH="$scyrox_favicon_hash" \
XSYD_FAVICON_URL="$xsyd_favicon_url" \
XSYD_FAVICON_HASH="$xsyd_favicon_hash" \
python3 - "$repo_root/home-manager/programs.nix" <<'PY'
import os
import re
import sys

path = sys.argv[1]
data = open(path, "r", encoding="utf-8").read()

def replace(url, new_url, new_hash):
    global data
    pattern = rf'url = "{re.escape(url)}";\n\s+hash = "sha256-[^"]+";'
    replacement = f'url = "{new_url}";\n    hash = "{new_hash}";'
    updated, count = re.subn(pattern, replacement, data, flags=re.M)
    if count != 1:
        raise SystemExit(f"Pattern matched {count} times: {pattern}")
    data = updated

replace(
    os.environ["SCYROX_FAVICON_URL"],
    os.environ["SCYROX_FAVICON_URL"],
    os.environ["SCYROX_FAVICON_HASH"],
)
replace(
    os.environ["XSYD_FAVICON_URL"],
    os.environ["XSYD_FAVICON_URL"],
    os.environ["XSYD_FAVICON_HASH"],
)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(data)
PY

echo "Updated impactor to ${impactor_version}"
echo "Updated grepai to ${grepai_version}"
echo "Updated yazi plugins to ${yazi_rev}"
echo "Updated ModernX to ${modernx_rev}"
echo "Updated skill and favicon hashes"
