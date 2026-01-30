#!/usr/bin/env bash
set -euo pipefail

# host-profile.sh
# Collect a structured host profile for Linux machines.
# Supports section selection, markdown/json output, redaction, missing-tool reporting/install,
# section listing, minimal mode, and sudo-aware execution for privileged checks.

VERSION="2.4"

# Capture the exact command used to invoke this script (before we shift args during parsing).
INVOCATION_STR="$(printf '%q ' "$0" "$@")"
INVOCATION_STR="${INVOCATION_STR% }"  # trim trailing space

# ----------------------------
# Defaults / CLI options
# ----------------------------
FORMAT="md"          # md | json
OUTPUT_FILE=""       # if set, write report there
REDACT=0             # 1 enables redaction filter
SHOW_MISSING=0
INSTALL_MISSING=0
ALL=0
LIST_SECTIONS=0
MINIMAL=0
USE_SUDO=0
SECTIONS=()          # if empty, defaults based on --minimal or full set

usage() {
  cat <<'USAGE'
Usage:
  host-profile.sh [--all] [--minimal] [--section NAME]...
                  [--format md|json] [--output FILE]
                  [--redact] [--show-missing] [--install-missing]
                  [--sudo] [--list-sections] [--version] [--help]

Examples:
  host-profile.sh --all > host-profile.md
  host-profile.sh --minimal --output host-min.md
  host-profile.sh --section cpu --section video --format json --output host.json
  host-profile.sh --all --show-missing
  host-profile.sh --all --install-missing
  host-profile.sh --all --sudo --output host-profile.md
  host-profile.sh --list-sections

Notes:
  --output writes the *actual report* (same content as stdout), not a template.
  --redact scrubs common identifiers (MACs, IPs, UUIDs, serial-ish strings, SSIDs where obvious).
  --sudo enables privileged checks (SMART, some logs) using sudo when needed.
USAGE
}

die() { echo "ERROR: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) ALL=1; shift ;;
    --minimal) MINIMAL=1; shift ;;
    --section) [[ $# -ge 2 ]] || die "--section requires an argument"; SECTIONS+=("$2"); shift 2 ;;
    --format) [[ $# -ge 2 ]] || die "--format requires an argument"; FORMAT="$2"; shift 2 ;;
    --output) [[ $# -ge 2 ]] || die "--output requires a filename"; OUTPUT_FILE="$2"; shift 2 ;;
    --redact|--reduct) REDACT=1; shift ;;  # accept your typo too :)
    --show-missing) SHOW_MISSING=1; shift ;;
    --install-missing) INSTALL_MISSING=1; shift ;;
    --sudo) USE_SUDO=1; shift ;;
    --list-sections) LIST_SECTIONS=1; shift ;;
    --version) echo "$VERSION"; exit 0 ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

case "$FORMAT" in
  md|json) ;;
  *) die "--format must be 'md' or 'json' (got: $FORMAT)" ;;
esac

# Make sure nothing tries to open an interactive pager (and no surprise "info").
export PAGER=cat
export SYSTEMD_PAGER=cat
export SYSTEMD_LESS=""
export GIT_PAGER=cat
export LESS="-FRSX"
export MANPAGER=cat
export TERM="${TERM:-xterm}"

# ----------------------------
# Helpers
# ----------------------------
now_utc() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

have() { command -v "$1" >/dev/null 2>&1; }

# Basic redaction filter (best effort).
redact_stream() {
  if [[ "$REDACT" -eq 0 ]]; then
    cat
    return
  fi
  sed -E \
    -e 's/\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b/[REDACTED_MAC]/g' \
    -e 's/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/[REDACTED_IPv4]/g' \
    -e 's/\b([0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}\b/[REDACTED_IPv6]/g' \
    -e 's/\b[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\b/[REDACTED_UUID]/g' \
    -e 's/\b(SN|Serial|SERIAL|sn|serial)[[:space:]]*[:=][[:space:]]*[^[:space:]]+/\1: [REDACTED]/g' \
    -e 's/\b(SSID)[[:space:]]*[:=][[:space:]]*.+/\1: [REDACTED]/g'
}

# Run command in a controlled way (non-interactive).
run_cmd() {
  local cmd="$1"
  bash -c "$cmd" 2>&1 || true
}

# Run command, preferring sudo if enabled and needed.
run_cmd_maybe_sudo() {
  local cmd="$1"
  if [[ "$USE_SUDO" -eq 1 ]]; then
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      run_cmd "$cmd"
      return
    fi
    if have sudo; then
      # Use non-interactive sudo after early credential warm-up.
      sudo -n bash -c "$cmd" 2>&1 || true
      return
    fi
  fi
  run_cmd "$cmd"
}

sudo_init() {
  # If sudo mode enabled, warm up credentials once, early.
  if [[ "$USE_SUDO" -ne 1 ]]; then
    return 0
  fi
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    return 0
  fi
  if ! have sudo; then
    echo "WARN: --sudo requested but 'sudo' not found; privileged checks will run unprivileged." >&2
    return 0
  fi
  # Prompt once (if needed) and cache credentials.
  sudo -v || true
}

# JSON string escape (requires python3; almost always present).
json_escape() {
  # Emits escaped JSON string content (no surrounding quotes) with NO trailing newline.
  if have python3; then
    python3 -c 'import json,sys; sys.stdout.write(json.dumps(sys.stdin.read())[1:-1])'
  else
    # Best-effort fallback (kept newline-free).
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g' | tr -d '\n'
  fi
}

# Fetch section items into global array SECTION_ITEMS without requiring bash namerefs.
SECTION_ITEMS=()
get_section_items() {
  # Populate global SECTION_ITEMS from section_<name> array.
  # Uses bash nameref (bash >= 4.3) to avoid eval/awk and to behave well with set -u.
  local sec="$1"
  local var="section_${sec}"

  SECTION_ITEMS=()
  if declare -p "$var" >/dev/null 2>&1; then
    local -n _ref="$var"
    SECTION_ITEMS=("${_ref[@]}")
  fi
}

# ----------------------------
# Commands by section
# ----------------------------

declare -A PKG_FOR_CMD=(
  [lscpu]="util-linux"
  [lsblk]="util-linux"
  [blkid]="util-linux"
  [lspci]="pciutils"
  [lsusb]="usbutils"
  [dmidecode]="dmidecode"
  [mokutil]="mokutil"
  [ethtool]="ethtool"
  [iw]="iw"
  [nmcli]="NetworkManager"
  [inxi]="inxi"
  [lshw]="lshw"
  [glxinfo]="mesa-demos"
  [xrandr]="xrandr"
  [edid-decode]="edid-decode"
  [smartctl]="smartmontools"
  [nvme]="nvme-cli"
  [rfkill]="rfkill"
  [fwupdmgr]="fwupd"
  [upower]="upower"
  [loginctl]="systemd"
  [journalctl]="systemd"
)

# Section registry (for --list-sections)
declare -A SECTION_DESC=(
  [base]="OS basics, kernel, hostname, secure boot"
  [cpu]="CPU model/features (lscpu)"
  [memory]="RAM summary (free), vmstat sample"
  [pci]="PCI devices (lspci -nnk)"
  [usb]="USB devices (lsusb)"
  [storage]="block devices, fstab, nvme list, SMART (optional sudo)"
  [network]="interfaces, addresses, routes, NM, wifi, ethtool"
  [video]="xrandr, DRM connectors/EDID, edid-decode, glxinfo"
  [session]="session env, loginctl, running WMs"
  [firmware]="dmesg firmware-ish, fwupdmgr devices"
  [power]="upower, tlp-stat"
  [logs]="journal warnings/errors (tail)"
)

declare -a section_base=(
  "Date / Uptime|||date; uptime|||0"
  "Kernel / Arch|||uname -a|||0"
  "OS release|||cat /etc/os-release 2>/dev/null || true|||0"
  "Hostname|||hostnamectl 2>/dev/null || hostname|||0"
  "Secure Boot (if available)|||mokutil --sb-state 2>/dev/null || true|||0"
)

declare -a section_cpu=(
  "lscpu|||lscpu|||0"
)

declare -a section_memory=(
  "free -h|||free -h|||0"
  "vmstat (short)|||vmstat -S M 1 5 2>/dev/null || true|||0"
)

declare -a section_pci=(
  "lspci -nnk|||lspci -nnk|||0"
)

declare -a section_usb=(
  "lsusb|||lsusb|||0"
)

# NOTE: escape runtime vars like $d as \$d to avoid expansion at script parse time (set -u).
declare -a section_storage=(
  "lsblk -f|||lsblk -f|||0"
  "blkid|||blkid 2>/dev/null || true|||0"
  "/etc/fstab|||cat /etc/fstab 2>/dev/null || true|||0"
  "nvme list|||nvme list 2>/dev/null || true|||0"
  "smartctl (best effort; prefers sudo if --sudo)|||for d in /dev/nvme*n1 /dev/sd[a-z]; do [[ -e \"\$d\" ]] || continue; echo \"== \$d ==\"; smartctl -a \"\$d\" 2>&1 || true; echo; done|||1"
)

declare -a section_network=(
  "ip link|||ip link|||0"
  "ip addr|||ip addr|||0"
  "ip route|||ip route|||0"
  "resolv.conf|||cat /etc/resolv.conf 2>/dev/null || true|||0"
  "nmcli|||nmcli general status; nmcli dev status|||0"
  "rfkill|||rfkill list 2>/dev/null || true|||0"
  "iw dev|||iw dev 2>/dev/null || true|||0"
  "ethtool (best effort)|||for i in \$(ls /sys/class/net 2>/dev/null | tr '\n' ' '); do echo \"== \$i ==\"; ethtool \"\$i\" 2>/dev/null || true; echo; done|||0"
)

declare -a section_video=(
  "xrandr --verbose (displays + modes)|||xrandr --verbose|||0"
  "DRM connectors (EDID presence)|||ls -1 /sys/class/drm/ 2>/dev/null | grep -E \"card.*(HDMI|DP|eDP)\" || true; echo; for d in /sys/class/drm/card*-*/edid; do [[ -e \"\$d\" ]] || continue; echo \"\$d : \$(wc -c < \"\$d\" 2>/dev/null | tr -d ' ') bytes (read)\"; done|||0"
  "edid-decode (for readable EDIDs)|||for ed in /sys/class/drm/*/edid /sys/class/drm/card*-*/edid; do [[ -e \"\$ed\" ]] || continue; b=\$(wc -c < \"\$ed\" 2>/dev/null | tr -d ' '); [[ \"\${b:-0}\" -gt 0 ]] || continue; echo \"== \$ed ==\"; edid-decode \"\$ed\" | sed -n \"1,220p\" || true; echo; done|||0"
  "glxinfo -B|||glxinfo -B|||0"
)

declare -a section_session=(
  "Environment basics|||echo \"XDG_SESSION_TYPE=\${XDG_SESSION_TYPE:-}\"; echo \"DESKTOP_SESSION=\${DESKTOP_SESSION:-}\"; echo \"GDMSESSION=\${GDMSESSION:-}\"|||0"
  "loginctl session-status (best effort)|||loginctl session-status 2>/dev/null || true|||0"
  "Running WMs (best effort)|||pgrep -a i3 || true; pgrep -a sway || true; pgrep -a gnome-shell || true; pgrep -a kwin_wayland || true; pgrep -a mate-session || true|||0"
)

declare -a section_firmware=(
  "dmesg (firmware-ish, short)|||dmesg -T 2>/dev/null | grep -Ei \"(firmware|microcode|dmi|acpi|i915)\" | tail -n 200 || true|||0"
  "fwupdmgr (if available)|||fwupdmgr get-devices 2>/dev/null || true|||0"
)

declare -a section_power=(
  "upower (if available)|||upower -d 2>/dev/null || true|||0"
  "TLP status (if available)|||tlp-stat -s 2>/dev/null || true|||0"
)

declare -a section_logs=(
  "journalctl (boot warnings/errors, short)|||journalctl -b -p warning --no-pager 2>/dev/null | tail -n 200 || true|||1"
)

# Default section sets
default_sections_full=(base cpu memory pci usb storage network video session firmware power logs)
default_sections_minimal=(base cpu pci storage network video session)

# If --list-sections, print and exit.
if [[ "$LIST_SECTIONS" -eq 1 ]]; then
  echo "Available sections:"
  for s in "${!SECTION_DESC[@]}"; do
    printf "  %-10s - %s\n" "$s" "${SECTION_DESC[$s]}"
  done | sort
  echo
  echo "Sets:"
  echo "  --minimal => ${default_sections_minimal[*]}"
  echo "  --all     => ${default_sections_full[*]}"
  exit 0
fi

# Resolve section list
if [[ "$ALL" -eq 1 ]]; then
  SECTIONS=("${default_sections_full[@]}")
elif [[ "${#SECTIONS[@]}" -eq 0 ]]; then
  if [[ "$MINIMAL" -eq 1 ]]; then
    SECTIONS=("${default_sections_minimal[@]}")
  else
    SECTIONS=("${default_sections_full[@]}")
  fi
fi

# Validate section names early
for s in "${SECTIONS[@]}"; do
  [[ -n "${SECTION_DESC[$s]:-}" ]] || die "Unknown section: $s (try --list-sections)"

done

# Warm up sudo credentials once, early (after we know sections are valid).
sudo_init

# ----------------------------
# Missing tool detection
# ----------------------------
declare -A NEED_CMDS=(
  [base]="date uptime uname cat hostnamectl mokutil"
  [cpu]="lscpu"
  [memory]="free vmstat"
  [pci]="lspci"
  [usb]="lsusb"
  [storage]="lsblk blkid nvme smartctl cat"
  [network]="ip nmcli rfkill iw ethtool cat"
  [video]="xrandr edid-decode glxinfo ls wc sed"
  [session]="loginctl pgrep"
  [firmware]="dmesg fwupdmgr grep tail"
  [power]="upower tlp-stat"
  [logs]="journalctl tail"
)

collect_missing() {
  local missing=()
  local sec
  for sec in "${SECTIONS[@]}"; do
    local cmds="${NEED_CMDS[$sec]:-}"
    for c in $cmds; do
      [[ "$c" == "cat" || "$c" == "ls" || "$c" == "wc" || "$c" == "sed" || "$c" == "tail" || "$c" == "grep" ]] && continue
      have "$c" || missing+=("$c")
    done
  done
  printf "%s\n" "${missing[@]}" | awk '!seen[$0]++'
}

missing_cmds="$(collect_missing || true)"
missing_pkgs=()

if [[ -n "${missing_cmds// }" ]]; then
  while IFS= read -r c; do
    [[ -z "$c" ]] && continue
    if [[ -n "${PKG_FOR_CMD[$c]:-}" ]]; then
      missing_pkgs+=("${PKG_FOR_CMD[$c]}")
    else
      missing_pkgs+=("<??> (for $c)")
    fi
  done <<<"$missing_cmds"
fi

missing_pkgs_uniq="$(printf "%s\n" "${missing_pkgs[@]}" | awk '!seen[$0]++')"

if [[ "$SHOW_MISSING" -eq 1 || "$INSTALL_MISSING" -eq 1 ]]; then
  {
    echo "== Missing commands =="
    if [[ -z "${missing_cmds// }" ]]; then
      echo "None."
    else
      echo "$missing_cmds"
    fi
    echo
    echo "== Suggested Fedora packages =="
    if [[ -z "${missing_pkgs_uniq// }" ]]; then
      echo "None."
    else
      echo "$missing_pkgs_uniq"
      echo
      if have dnf; then
        echo "Install command (suggested):"
        echo "  sudo dnf install -y $(echo "$missing_pkgs_uniq" | grep -v '^\<\?\?\>' | tr '\n' ' ')"
      fi
    fi
    echo
  } | redact_stream >&2
fi

if [[ "$INSTALL_MISSING" -eq 1 ]]; then
  have dnf || die "--install-missing requires dnf"
  if [[ -n "${missing_pkgs_uniq// }" ]]; then
    pkgs="$(echo "$missing_pkgs_uniq" | grep -v '^\<\?\?\>' | tr '\n' ' ' | xargs || true)"
    if [[ -n "${pkgs// }" ]]; then
      if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        dnf install -y $pkgs
      else
        sudo dnf install -y $pkgs
      fi
    fi
  fi
fi

parse_item() {
  # Parse "label|||cmd|||needs_sudo" into provided variable names.
  # Usage: parse_item "$item" label_var cmd_var needs_sudo_var
  local item="$1"
  local __label_ref="$2"
  local __cmd_ref="$3"
  local __sudo_ref="$4"

  # IMPORTANT: do NOT name locals "label/cmd/needs_sudo" because callers often
  # use those exact variable names, and bash's dynamic scoping would cause us
  # to write to our own locals instead of the caller's.
  local _label _rest _cmd _needs_sudo
  _label="${item%%|||*}"
  _rest="${item#*|||}"
  _cmd="${_rest%%|||*}"
  _needs_sudo="${_rest#*|||}"

  # If the delimiter was missing, make best-effort defaults.
  [[ "$item" == *"|||"* ]] || _cmd=""
  [[ "$_rest" == *"|||"* ]] || _needs_sudo="0"

  _label="${_label:-}"
  _cmd="${_cmd:-}"
  _needs_sudo="${_needs_sudo:-0}"

  printf -v "$__label_ref" '%s' "$_label"
  printf -v "$__cmd_ref" '%s' "$_cmd"
  printf -v "$__sudo_ref" '%s' "$_needs_sudo"
}


# ----------------------------
# Emit report
# ----------------------------
emit_md() {
  echo "# host-profile report"
  echo
  echo "- Script version: \`$VERSION\`"
  echo "- Timestamp (UTC): \`$(now_utc)\`"
  echo "- Host: \`$(hostname 2>/dev/null || true)\`"
  echo "- Invocation: \`$INVOCATION_STR\`"
  echo "- Format: \`$FORMAT\`"
  echo "- Sections: \`${SECTIONS[*]}\`"
  echo "- Redaction: \`$([[ "$REDACT" -eq 1 ]] && echo on || echo off)\`"
  echo "- Sudo mode: \`$([[ "$USE_SUDO" -eq 1 ]] && echo on || echo off)\`"
  echo

  local sec
  for sec in "${SECTIONS[@]}"; do
    echo "## ${sec^^}"
    echo
    echo "_${SECTION_DESC[$sec]}_"
    echo

    get_section_items "$sec"
    local items=("${SECTION_ITEMS[@]}")
    if [[ "${#items[@]}" -eq 0 ]]; then
      echo "_No commands defined for section: $sec_"
      echo
      continue
    fi

    local item label cmd needs_sudo
    for item in "${items[@]}"; do
      # With `set -u`, a `local var` that hasn't been assigned yet is still
      # considered "unset". Always initialize before parsing.
      label=""; cmd=""; needs_sudo="0"
      parse_item "$item" label cmd needs_sudo

      # Defensive: skip malformed items rather than crashing.
      [[ -n "$cmd" ]] || continue

      echo "### $label"
      echo
      echo '```'
      if [[ "${needs_sudo:-0}" -eq 1 && "$USE_SUDO" -eq 1 ]]; then
        echo "\$ sudo bash -c $cmd"
      else
        echo "\$ bash -c $cmd"
      fi
      echo '```'
      echo
      echo '```'
      if [[ "${needs_sudo:-0}" -eq 1 ]]; then
        run_cmd_maybe_sudo "$cmd" | redact_stream
      else
        run_cmd "$cmd" | redact_stream
      fi
      echo '```'
      echo
    done
  done
}

emit_json() {
  {
    echo '{'
    echo '  "meta": {'
    echo -n '    "script_version": "'; echo -n "$VERSION" | json_escape; echo '",'
    echo -n '    "timestamp_utc": "'; now_utc | tr -d "\n" | json_escape; echo '",'
    echo -n '    "host": "'; (hostname 2>/dev/null || true) | tr -d "\n" | json_escape; echo '",'
    echo -n '    "invocation": "'; echo -n "$INVOCATION_STR" | json_escape; echo '",'
    echo -n '    "redaction": '; [[ "$REDACT" -eq 1 ]] && echo 'true,' || echo 'false,'
    echo -n '    "sudo_mode": '; [[ "$USE_SUDO" -eq 1 ]] && echo 'true,' || echo 'false,'
    echo -n '    "sections": "'; echo -n "${SECTIONS[*]}" | json_escape; echo '"'
    echo '  },'
    echo '  "sections": {'

    local first_sec=1
    local sec
    for sec in "${SECTIONS[@]}"; do
      [[ $first_sec -eq 1 ]] || echo ','
      first_sec=0

      echo -n "    \"${sec}\": ["
      get_section_items "$sec"
      local items=("${SECTION_ITEMS[@]}")
      local first_item=1
      local item label cmd needs_sudo out
      for item in "${items[@]}"; do
        # With `set -u`, a `local var` that hasn't been assigned yet is still
        # considered "unset". Always initialize before parsing.
        label=""; cmd=""; needs_sudo="0"
        parse_item "$item" label cmd needs_sudo

        # Defensive: skip malformed items rather than crashing.
        if [[ -z "$cmd" ]]; then
          continue
        fi

        if [[ "${needs_sudo:-0}" -eq 1 ]]; then
          out="$(run_cmd_maybe_sudo "$cmd" | redact_stream)"
        else
          out="$(run_cmd "$cmd" | redact_stream)"
        fi

        [[ $first_item -eq 1 ]] || echo -n ','
        first_item=0

        echo
        echo -n '      {"label":"'; echo -n "$label" | json_escape; echo -n '",'
        echo -n '"cmd":"'; echo -n "$cmd" | json_escape; echo -n '",'
        echo -n '"needs_sudo":'; [[ "${needs_sudo:-0}" -eq 1 ]] && echo -n 'true,' || echo -n 'false,'
        echo -n '"output":"'; echo -n "$out" | json_escape; echo -n '"}'
      done
      echo
      echo -n '    ]'
    done

    echo
    echo '  }'
    echo '}'
  }
}

# Choose output stream
if [[ -n "$OUTPUT_FILE" ]]; then
  mkdir -p "$(dirname "$OUTPUT_FILE")" 2>/dev/null || true
  if [[ "$FORMAT" == "md" ]]; then
    emit_md | tee "$OUTPUT_FILE" >/dev/null
  else
    emit_json | tee "$OUTPUT_FILE" >/dev/null
  fi
else
  if [[ "$FORMAT" == "md" ]]; then
    emit_md
  else
    emit_json
  fi
fi

