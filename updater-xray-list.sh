#!/usr/bin/env bash
set -Euo pipefail

WORKDIR="/opt/remnanode"
ASSET_DIR="${WORKDIR}/xray-list"

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

fatal() { printf "[!] %s\n" "$*" >&2; exit 1; }

fetch() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 --retry-delay 1 "$url" -o "$out" && return 0
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url" && return 0
  fi
  return 1
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
install -d -m 0755 "$ASSET_DIR"

cat <<'BANNER'

██╗  ██╗ ██████╗ ██╗  ██╗      ██╗   ██╗██╗  ██╗██╗     
██║  ██║██╔═████╗██║  ██║      ██║   ██║╚██╗██╔╝██║     
███████║██║██╔██║███████║█████╗██║   ██║ ╚███╔╝ ██║     
╚════██║████╔╝██║╚════██║╚════╝██║   ██║ ██╔██╗ ██║     
     ██║╚██████╔╝     ██║      ╚██████╔╝██╔╝ ██╗███████╗
     ╚═╝ ╚═════╝      ╚═╝       ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                        
BANNER

printf "Welcome to 404 Updater Xray List!\n\n"
echo "This updater downloads and updates:"
echo " - v2fly geosite (dlc)          -> geosite_v2fly.dat"
echo " - v2fly geoip                  -> geoip_v2fly.dat"
echo " - runetfreedom geosite (RU)    -> geosite_ru.dat"
echo " - runetfreedom geoip (RU)      -> geoip_ru.dat"
echo " - NetworkKeeper geosite        -> geosite_antifilter.dat"
echo " - NetworkKeeper geoip          -> geoip_antifilter.dat"
echo " - Re-filter geosite            -> geosite_refilter.dat"
echo " - Re-filter geoip              -> geoip_refilter.dat"
echo " - ru_gov_zapret                -> zapret.dat"
echo

printf "[*] Using temp dir: %s\n" "$TMP_DIR"
printf "[*] Target asset dir: %s\n" "$ASSET_DIR"

FILES=(
  geosite_v2fly.dat
  geoip_v2fly.dat
  geosite_ru.dat
  geoip_ru.dat
  geosite_antifilter.dat
  geoip_antifilter.dat
  geosite_refilter.dat
  geoip_refilter.dat
  zapret.dat
)

URLS=(
  "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"
  "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"
  "https://github.com/runetfreedom/russia-blocked-geosite/releases/latest/download/geosite.dat"
  "https://github.com/runetfreedom/russia-blocked-geoip/releases/latest/download/geoip.dat"
  "https://github.com/NetworkKeeper/v2ray-rules-ru/releases/latest/download/geosite.dat"
  "https://github.com/NetworkKeeper/v2ray-rules-ru/releases/latest/download/geoip.dat"
  "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/geosite.dat"
  "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/geoip.dat"
  "https://github.com/kutovoys/ru_gov_zapret/releases/latest/download/zapret.dat"
)

echo "[i] Checking existing assets under ${ASSET_DIR}:"
for f in "${FILES[@]}"; do
  if [[ -f "${ASSET_DIR}/${f}" ]]; then
    echo " - ${f}: present (will refresh)"
  else
    echo " - ${f}: missing (will download)"
  fi
done

for i in "${!FILES[@]}"; do
  name="${FILES[$i]}"
  url="${URLS[$i]}"
  printf "[DL] %-26s <- %s ... " "$name" "$url"
  if fetch "$url" "$TMP_DIR/$name"; then
    printf "%b\n" "${GREEN}[OK]${NC}"
  else
    printf "%b\n" "${RED}[FAIL]${NC}"
  fi
done

echo "[*] Updating files in ${ASSET_DIR}"

updated=0
kept=0
missing=0

for f in "${FILES[@]}"; do
  if [[ -s "$TMP_DIR/$f" ]]; then
    if cp -f "$TMP_DIR/$f" "$ASSET_DIR/$f" && chmod 0644 "$ASSET_DIR/$f"; then
      printf "%b %s\n" "${GREEN}[OK] Updated:${NC}" "$f"
      ((updated++))
    else
      printf "%b %s\n" "${RED}[ERR]${NC}" "failed to write $f into ${ASSET_DIR}"
      ((missing++))
    fi
  else
    if [[ -f "$ASSET_DIR/$f" ]]; then
      printf "%b %s\n" "${YELLOW}[KEEP]${NC}" "$f - keeping existing file"
      ((kept++))
    else
      printf "%b %s\n" "${RED}[ERR]${NC}" "$f is missing and could not be downloaded"
      ((missing++))
    fi
  fi
done

printf "[i] Summary: updated=%d, kept=%d, missing=%d\n" "$updated" "$kept" "$missing"
if (( missing > 0 )); then
  fatal "One or more required files are missing or failed to update."
fi

printf "[✓] Lists are present under: %s\n" "$ASSET_DIR"

exit 0