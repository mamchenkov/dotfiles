#!/usr/bin/env bash
set -euo pipefail

# host-profile.sh
# Collect a structured host profile for Linux machines.
# Supports section selection, markdown/json output, redaction, missing-tool reporting/install,
# section listing, minimal mode, and sudo-aware execution for privileged checks.
# Requires: Bash 4.3+ (for associative arrays and namerefs).

VERSION="3.3"

# Capture the exact command used to invoke this script (before we shift args during parsing).
INVOCATION_STR="$(printf '%q ' "$0" "$@")"
INVOCATION_STR="${INVOCATION_STR% }"  # trim trailing space

# ----------------------------
# Defaults / CLI options
# ----------------------------
FORMAT="md"          # md | json
OUTPUT_FILE=""       # if set, write report there
REDACT=0             # 1 = redaction on (opt-in via --redact); 0 = off by default for local/controlled use
SHOW_MISSING=0
INSTALL_MISSING=0
ALL=0
LIST_SECTIONS=0
MINIMAL=0
MODE=""              # inventory | diagnostic | full (empty = full when --all, else based on --minimal)
USE_SUDO=1           # 1 = use sudo when command needs it (default); 0 = never use sudo (--no-sudo)
SECTIONS=()          # if empty, defaults based on --mode / --minimal / --all

usage() {
  cat <<'USAGE'
Usage:
  host-profile.sh [--all] [--minimal] [--mode inventory|diagnostic|full]
                  [--section NAME]... [--format md|json] [--output FILE]
                  [--redact] [--show-missing] [--install-missing]
                  [--no-sudo] [--list-sections] [--version] [--help]

Options:
  Section selection (mutually exclusive with explicit --section):
    --all              Collect all sections (base, cpu, memory, pci, usb, storage, network,
                       video, session, firmware, power, boot, perf, logs, security, packages, services).
    --minimal          Collect a small subset: base, cpu, perf, pci, storage, network, session.
    --mode MODE        Use a predefined set: inventory (hardware/device list), diagnostic
                       (boot, perf, logs), full (same as --all), or minimal (same as --minimal).
    --section NAME     Add section NAME; can be repeated. Use --list-sections to see names.
                       Overrides --all/--minimal/--mode when at least one --section is given.

  Output:
    --format md|json   Report format: markdown (default) or JSON.
    --output FILE     Write report to FILE only (nothing on stdout). Creates parent dirs if needed.

  Privacy and privileges:
    --redact           Enable redaction (off by default). Scrubs MACs, IPs, UUIDs, serials,
                       SSIDs, machine/boot IDs, asset tags, URLs, tokens. Use for sharing reports.
    --no-sudo          Never use sudo (default: use sudo when a command needs it, e.g. SMART, logs).
    --sudo             Use sudo for privileged checks (default).

  Tooling:
    --show-missing     Print missing commands and suggested packages to stderr (no report).
    --install-missing  Same as --show-missing, then run dnf install for suggested packages (requires dnf).
    --list-sections   Print available sections and predefined sets, then exit.
    --version         Print script version and exit.
    --help, -h        Show this help and exit.

Examples:

  Full report as JSON (everything, to a file):
    host-profile.sh --all --format json --output host.json

  Single section to stdout (markdown):
    host-profile.sh --section base
    host-profile.sh --section cpu --format md

  Several sections in markdown (to stdout or file):
    host-profile.sh --section cpu --section storage --section network
    host-profile.sh --section security --section boot --output security-and-boot.md

  Predefined modes with format and output:
    host-profile.sh --mode inventory --format md --output host-inventory.md
    host-profile.sh --mode diagnostic --format json --output host-diagnostic.json

  Combining privacy/privileges with section selection:
    host-profile.sh --all --redact --output host-redacted.md
    host-profile.sh --mode inventory --no-sudo --output host-inventory-no-sudo.md

  Check and install missing tools (no report):
    host-profile.sh --all --show-missing
    host-profile.sh --all --install-missing

  List what can be collected:
    host-profile.sh --list-sections

Notes:
  With --output, the report is written only to FILE; stdout is empty (so do not redirect stdout to the same file).
  Redaction is off by default (for local/controlled use); pass --redact to scrub sensitive data when sharing.
USAGE
}

die() { echo "ERROR: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) ALL=1; MODE="full"; shift ;;
    --minimal) MINIMAL=1; MODE="minimal"; shift ;;
    --mode) [[ $# -ge 2 ]] || die "--mode requires an argument (inventory|diagnostic|full|minimal)"; MODE="$2"; shift 2 ;;
    --section) [[ $# -ge 2 ]] || die "--section requires an argument"; SECTIONS+=("$2"); shift 2 ;;
    --format) [[ $# -ge 2 ]] || die "--format requires an argument"; FORMAT="$2"; shift 2 ;;
    --output) [[ $# -ge 2 ]] || die "--output requires a filename"; OUTPUT_FILE="$2"; shift 2 ;;
    --redact|--reduct) REDACT=1; shift ;;  # --reduct is a typo alias for --redact
    --show-missing) SHOW_MISSING=1; shift ;;
    --install-missing) INSTALL_MISSING=1; shift ;;
    --no-sudo) USE_SUDO=0; shift ;;
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

if [[ -n "$MODE" ]]; then
  case "$MODE" in
    inventory|diagnostic|full|minimal) ;;
    *) die "--mode must be 'inventory', 'diagnostic', 'full', or 'minimal' (got: $MODE)" ;;
  esac
fi

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
    -e '/\.(fc[0-9]+|noarch|x86_64|i686)\b/! s/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/[REDACTED_IPv4]/g' \
    -e 's/\b([0-9A-Fa-f]{0,4}:){4,7}[0-9A-Fa-f]{0,4}\b/[REDACTED_IPv6]/g' \
    -e 's/\b[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\b/[REDACTED_UUID]/g' \
    -e 's/\b(SN|Serial|SERIAL|sn|serial)[[:space:]]*[:=][[:space:]]*[^[:space:]]+/\1: [REDACTED]/g' \
    -e 's/\b(SSID)[[:space:]]*[:=][[:space:]]*.+/\1: [REDACTED]/g' \
    -e 's/\b(Machine ID|machine-id|machine_id)[[:space:]]*[:=][[:space:]]*[0-9a-f]{32}\b/\1: [REDACTED]/g' \
    -e 's/\b(Boot ID|boot-id|boot_id)[[:space:]]*[:=][[:space:]]*[0-9a-f]{32}\b/\1: [REDACTED]/g' \
    -e 's/\b(Machine ID|machine-id|machine_id)[[:space:]]*[:=][[:space:]]*[0-9a-f-]{36}\b/\1: [REDACTED]/g' \
    -e 's/\b(Boot ID|boot-id|boot_id)[[:space:]]*[:=][[:space:]]*[0-9a-f-]{36}\b/\1: [REDACTED]/g' \
    -e 's/\b(Asset Tag|asset.tag|asset_tag)[[:space:]]*[:=][[:space:]]*[^[:space:]]+/\1: [REDACTED]/g' \
    -e 's/\b(https?|ftp):\/\/[^[:space:])\]]+/[REDACTED_URL]/g' \
    -e 's/\b(eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,})\b/[REDACTED_TOKEN]/g'
}

# Max bytes per stream (stdout/stderr) before truncation. Used for execution metadata.
MAX_OUTPUT_BYTES="${MAX_OUTPUT_BYTES:-262144}"

# Run command in a controlled way (non-interactive). Stdout and stderr merged (legacy).
run_cmd() {
  local cmd="$1"
  bash -c "$cmd" 2>&1 || true
}

# Run command, preferring sudo if enabled and needed. Stdout and stderr merged (legacy).
run_cmd_maybe_sudo() {
  local cmd="$1"
  if [[ "$USE_SUDO" -eq 1 ]]; then
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      run_cmd "$cmd"
      return
    fi
    if have sudo; then
      sudo -n bash -c "$cmd" 2>&1 || true
      return
    fi
  fi
  run_cmd "$cmd"
}

# Internal: run command with separate stdout/stderr; caller redirects. Returns exit code.
_run_cmd_separate() {
  local cmd="$1" use_sudo="${2:-0}"
  if [[ "$use_sudo" -eq 1 && "$USE_SUDO" -eq 1 ]]; then
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      bash -c "$cmd"
      return $?
    fi
    if have sudo; then
      sudo -n bash -c "$cmd"
      return $?
    fi
  fi
  bash -c "$cmd"
  return $?
}

# Run command and set execution metadata globals: CMD_STDOUT, CMD_STDERR, CMD_EXIT_CODE,
# CMD_DURATION_MS, CMD_TRUNCATED (0|1), CMD_TRUNCATED_BYTES (limit used when truncated).
# Output is redacted and optionally truncated to MAX_OUTPUT_BYTES per stream.
run_cmd_with_metadata() {
  local cmd="$1" needs_sudo="${2:-0}"
  local tmp_out tmp_err start_ms end_ms out_len err_len
  CMD_STDOUT="" CMD_STDERR="" CMD_EXIT_CODE=0 CMD_DURATION_MS=0 CMD_TRUNCATED=0 CMD_TRUNCATED_BYTES=0
  tmp_out=$(mktemp) tmp_err=$(mktemp)
  start_ms=$(date +%s%3N 2>/dev/null || echo $(($(date +%s) * 1000)))
  set +e
  _run_cmd_separate "$cmd" "$needs_sudo" >"$tmp_out" 2>"$tmp_err"
  CMD_EXIT_CODE=$?
  set -e
  end_ms=$(date +%s%3N 2>/dev/null || echo $(($(date +%s) * 1000)))
  CMD_DURATION_MS=$(( end_ms - start_ms ))
  out_len=$(wc -c <"$tmp_out")
  err_len=$(wc -c <"$tmp_err")
  if [[ "$out_len" -gt "$MAX_OUTPUT_BYTES" ]]; then
    CMD_STDOUT=$(head -c "$MAX_OUTPUT_BYTES" <"$tmp_out" | redact_stream)
    CMD_STDOUT+=$'\n... [truncated]'
    CMD_TRUNCATED=1
    CMD_TRUNCATED_BYTES=$MAX_OUTPUT_BYTES
  else
    CMD_STDOUT=$(redact_stream <"$tmp_out")
  fi
  if [[ "$err_len" -gt "$MAX_OUTPUT_BYTES" ]]; then
    CMD_STDERR=$(head -c "$MAX_OUTPUT_BYTES" <"$tmp_err" | redact_stream)
    CMD_STDERR+=$'\n... [truncated]'
    CMD_TRUNCATED=1
    [[ "$CMD_TRUNCATED_BYTES" -eq 0 ]] && CMD_TRUNCATED_BYTES=$MAX_OUTPUT_BYTES
  else
    CMD_STDERR=$(redact_stream <"$tmp_err")
  fi
  rm -f "$tmp_out" "$tmp_err"
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
  [dmidecode]="dmidecode"
  [upower]="upower"
  [loginctl]="systemd"
  [journalctl]="systemd"
  [systemd-analyze]="systemd"
  [systemctl]="systemd"
  [ps]="procps-ng"
  [head]="coreutils"
  [rpm]="rpm"
  [dnf]="dnf"
  [getenforce]="libselinux-utils"
  [sestatus]="policycoreutils"
  [firewall-cmd]="firewalld"
  [timedatectl]="systemd"
  [needs-restarting]="dnf-utils"
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
  [boot]="boot performance (systemd-analyze)"
  [perf]="top offenders snapshot (cpu/mem)"
  [logs]="journal warnings/errors (tail)"
  [security]="SELinux (getenforce), firewalld status"
  [packages]="installed RPMs (rpm -qa), repo sources"
  [services]="systemd enabled, running, failed units"
)

# Section item format: "label|||command|||needs_sudo" (needs_sudo is 0 or 1).
declare -a section_base=(
  "Date / Uptime|||date; uptime|||0"
  "Kernel / Arch|||uname -a|||0"
  "OS release|||cat /etc/os-release 2>/dev/null || true|||0"
  "Hostname|||hostnamectl 2>/dev/null || hostname|||0"
  "Secure Boot (if available)|||mokutil --sb-state 2>/dev/null || true|||0"
  "Time / NTP (timedatectl)|||timedatectl status 2>/dev/null || true|||0"
  "Updates pending (dnf check-update)|||dnf check-update 2>/dev/null | tail -20 || true|||0"
  "Reboot required (needs-restarting -r; exit_code 1 = reboot needed)|||needs-restarting -r 2>/dev/null|||0"
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
  "df -hP (filesystem usage)|||df -hP 2>/dev/null || df -h|||0"
  "blkid|||blkid 2>/dev/null || true|||0"
  "/etc/fstab|||cat /etc/fstab 2>/dev/null || true|||0"
  "nvme list|||nvme list 2>/dev/null || true|||0"
  "NVMe wear summary (percent_used, power_on_hours)|||for c in /dev/nvme[0-9]; do [[ -e \"\$c\" ]] || continue; echo \"== \$c ==\"; nvme smart-log \"\$c\" 2>/dev/null | awk '/percentage used|Percentage Used/{gsub(/%/,\"\"); print \"nvme_wear_percent_used:\", \$NF} /Power On Hours|power_on_hours/{print \"power_on_hours:\", \$NF}' || true; done|||0"
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
  "iw station dump (link quality, RSSI, bitrate)|||for iface in \$(iw dev 2>/dev/null | awk '/Interface/{print \$2}'); do echo \"== \$iface ==\"; iw dev \"\$iface\" station dump 2>/dev/null || true; done|||0"
  "ethtool (best effort)|||for i in \$(ls /sys/class/net 2>/dev/null | tr '\n' ' '); do echo \"== \$i ==\"; ethtool \"\$i\" 2>/dev/null || true; echo; done|||0"
  "ethtool -i (driver/firmware per iface)|||for i in \$(ls /sys/class/net 2>/dev/null | tr '\n' ' '); do echo \"== \$i ==\"; ethtool -i \"\$i\" 2>/dev/null || true; echo; done|||0"
  "modinfo wireless (iwlwifi etc)|||for m in iwlwifi iwlmvm ath9k ath10k_pci rtw88; do modinfo \"\$m\" 2>/dev/null | head -20 || true; echo; done|||0"
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
  "fwupdmgr devices|||fwupdmgr get-devices 2>/dev/null || true|||0"
  "fwupdmgr available updates|||fwupdmgr get-updates 2>/dev/null || true|||0"
  "BIOS/DMI (type 0)|||dmidecode -t bios 2>/dev/null || true|||1"
)

declare -a section_power=(
  "upower (if available)|||upower -d 2>/dev/null || true|||0"
  "TLP status (if available)|||tlp-stat -s 2>/dev/null || true|||0"
)


declare -a section_boot=(
  "systemd-analyze (summary)|||systemd-analyze 2>/dev/null || true|||0"
  "systemd-analyze blame (top 30)|||systemd-analyze blame 2>/dev/null | head -n 30 || true|||0"
  "systemd-analyze critical-chain (top 50)|||systemd-analyze critical-chain 2>/dev/null | head -n 50 || true|||0"
)

declare -a section_perf=(
  "Top memory consumers (ps, top 30)|||ps -eo pid,comm,%cpu,%mem --sort=-%mem 2>/dev/null | head -n 30 || true|||0"
  "Top CPU consumers (ps, top 30)|||ps -eo pid,comm,%cpu,%mem --sort=-%cpu 2>/dev/null | head -n 30 || true|||0"
)

declare -a section_logs=(
  "journalctl (boot warnings/errors, short)|||journalctl -b -p warning --no-pager 2>/dev/null | tail -n 200 || true|||1"
  "journalctl (boot warnings/errors, filtered noisy apps, short)|||journalctl -b -p warning --no-pager 2>/dev/null | grep -Ev \"(telegram|Telegram|org\.telegram|xdg-desktop-portal|flatpak)\" | tail -n 200 || true|||1"
)

declare -a section_security=(
  "SELinux status|||getenforce 2>/dev/null || true|||0"
  "SELinux detailed (if available)|||sestatus 2>/dev/null || true|||0"
  "Firewalld status|||firewall-cmd --state 2>/dev/null || true|||0"
)

declare -a section_packages=(
  "Installed packages (rpm -qa, sorted)|||rpm -qa --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' 2>/dev/null | sort || rpm -qa 2>/dev/null | sort|||0"
  "Package repos (Fedora/DNF)|||dnf repoquery -a --installed --queryformat '%{name}\t%{repoid}' 2>/dev/null | sort -u || true|||0"
)

declare -a section_services=(
  "systemd enabled unit files|||systemctl list-unit-files --state=enabled --no-pager --no-legend 2>/dev/null || true|||0"
  "systemd running units|||systemctl list-units --state=running --no-pager --no-legend 2>/dev/null || true|||0"
  "systemd failed units|||systemctl list-units --state=failed --no-pager --no-legend 2>/dev/null || true|||0"
)

# Default section sets: inventory = hardware/device list; diagnostic = logs/perf/boot; full = all
default_sections_inventory=(base cpu pci usb storage network video session firmware power security packages services)
default_sections_diagnostic=(base boot perf logs)
default_sections_full=(base cpu memory pci usb storage network video session firmware power boot perf logs security packages services)
default_sections_minimal=(base cpu perf pci storage network video session)

# If --list-sections, print and exit.
if [[ "$LIST_SECTIONS" -eq 1 ]]; then
  echo "Available sections:"
  for s in "${!SECTION_DESC[@]}"; do
    printf "  %-10s - %s\n" "$s" "${SECTION_DESC[$s]}"
  done | sort
  echo
  echo "Sets:"
  echo "  --minimal   => ${default_sections_minimal[*]}"
  echo "  --mode inventory  => ${default_sections_inventory[*]}"
  echo "  --mode diagnostic => ${default_sections_diagnostic[*]}"
  echo "  --all / --mode full => ${default_sections_full[*]}"
  exit 0
fi

# Resolve section list
if [[ "$ALL" -eq 1 ]]; then
  SECTIONS=("${default_sections_full[@]}")
elif [[ -n "$MODE" ]]; then
  case "$MODE" in
    inventory)  SECTIONS=("${default_sections_inventory[@]}") ;;
    diagnostic) SECTIONS=("${default_sections_diagnostic[@]}") ;;
    full)       SECTIONS=("${default_sections_full[@]}") ;;
    minimal)    SECTIONS=("${default_sections_minimal[@]}") ;;
  esac
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
# Missing tool detection (keep in sync with section_* arrays when adding sections/commands)
# ----------------------------
declare -A NEED_CMDS=(
  [base]="date uptime uname cat hostnamectl mokutil timedatectl dnf needs-restarting"
  [cpu]="lscpu"
  [memory]="free vmstat"
  [perf]="ps head"
  [pci]="lspci"
  [usb]="lsusb"
  [storage]="lsblk blkid nvme smartctl cat"
  [network]="ip nmcli rfkill iw ethtool modinfo cat ls awk head"
  [video]="xrandr edid-decode glxinfo ls wc sed"
  [session]="loginctl pgrep"
  [firmware]="dmesg fwupdmgr dmidecode grep tail"
  [power]="upower tlp-stat"
  [boot]="systemd-analyze head"
  [logs]="journalctl tail"
  [security]="getenforce sestatus firewall-cmd"
  [packages]="rpm dnf sort"
  [services]="systemctl"
)

collect_missing() {
  local missing=()
  local sec
  for sec in "${SECTIONS[@]}"; do
    local cmds="${NEED_CMDS[$sec]:-}"
    for c in $cmds; do
      [[ "$c" == "cat" || "$c" == "ls" || "$c" == "wc" || "$c" == "sed" || "$c" == "tail" || "$c" == "grep" || "$c" == "sort" ]] && continue
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
    pkgs_arr=()
    while IFS= read -r p; do
      [[ -z "$p" ]] && continue
      [[ "$p" == "<??>"* ]] && continue
      pkgs_arr+=("$p")
    done <<<"$missing_pkgs_uniq"
    if [[ ${#pkgs_arr[@]} -gt 0 ]]; then
      if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        dnf install -y "${pkgs_arr[@]}"
      else
        sudo dnf install -y "${pkgs_arr[@]}"
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
  echo "- Profile mode: \`${MODE:-full}\`"
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
      echo "_No commands defined for section: ${sec}_"
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
      run_cmd_with_metadata "$cmd" "${needs_sudo:-0}"
      echo '```'
      if [[ "${needs_sudo:-0}" -eq 1 && "$USE_SUDO" -eq 1 ]]; then
        echo "\$ sudo bash -c $cmd"
      else
        echo "\$ bash -c $cmd"
      fi
      echo '```'
      echo
      echo '```'
      echo "$CMD_STDOUT"
      echo '```'
      if [[ -n "${CMD_STDERR// }" ]]; then
        echo
        echo "**stderr:**"
        echo '```'
        echo "$CMD_STDERR"
        echo '```'
      fi
      echo "- **exit_code:** $CMD_EXIT_CODE | **duration_ms:** $CMD_DURATION_MS"
      [[ "$CMD_TRUNCATED" -eq 1 ]] && echo "- **truncated:** true | **truncated_bytes:** $CMD_TRUNCATED_BYTES"
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
    echo -n '    "profile_mode": "'; echo -n "${MODE:-full}" | json_escape; echo '",'
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

        run_cmd_with_metadata "$cmd" "${needs_sudo:-0}"

        [[ $first_item -eq 1 ]] || echo -n ','
        first_item=0

        echo
        echo -n '      {"label":"'; echo -n "$label" | json_escape; echo -n '",'
        echo -n '"cmd":"'; echo -n "$cmd" | json_escape; echo -n '",'
        echo -n '"needs_sudo":'; [[ "${needs_sudo:-0}" -eq 1 ]] && echo -n 'true,' || echo -n 'false,'
        echo -n '"exit_code":'; echo -n "$CMD_EXIT_CODE"; echo -n ','
        echo -n '"duration_ms":'; echo -n "$CMD_DURATION_MS"; echo -n ','
        echo -n '"output":"'; echo -n "$CMD_STDOUT" | json_escape; echo -n '",'
        echo -n '"stderr":"'; echo -n "$CMD_STDERR" | json_escape; echo -n '",'
        echo -n '"truncated":'; [[ "$CMD_TRUNCATED" -eq 1 ]] && echo -n 'true' || echo -n 'false'; echo -n ','
        echo -n '"truncated_bytes":'; echo -n "$CMD_TRUNCATED_BYTES"; echo -n '}'
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

