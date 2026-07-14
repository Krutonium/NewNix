#!/usr/bin/env bash
# push-to-attic.sh — Build all derivations in a flake and push them to an Attic cache.
#
# Usage:
#   push-to-attic.sh [OPTIONS] [FLAKE_REF]
#
# Options:
#   -c, --cache CACHE_NAME   Attic cache name to push to (required, or set ATTIC_CACHE)
#   -j, --jobs N             Max parallel nix builds (default: $(nproc))
#   -s, --system SYSTEM      Override system (default: current system)
#   -d, --dry-run            Show what would be pushed without actually pushing
#   -k, --keep-going         Continue on build/push failures instead of aborting
#   -f, --filter REGEX       Only push outputs whose attr path matches REGEX
#   --no-build               Skip building; only push already-realised store paths
#   --include-checks         Also build checks.* outputs (skipped by default)
#   -h, --help               Show this help

set -euo pipefail
cd ~/NixOS
# ── Defaults ────────────────────────────────────────────────────────────────
FLAKE_REF="."
CACHE="${ATTIC_CACHE:-}"
JOBS="$(nproc)"
SYSTEM="$(nix eval --impure --raw --expr 'builtins.currentSystem' 2>/dev/null || echo "x86_64-linux")"
DRY_RUN=false
KEEP_GOING=false
FILTER=""
NO_BUILD=false
INCLUDE_CHECKS=false

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
err()     { echo -e "${RED}[ERR]${RESET}   $*" >&2; }
die()     { err "$*"; exit 1; }

# ── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--cache)         CACHE="$2";       shift 2 ;;
    -j|--jobs)          JOBS="$2";        shift 2 ;;
    -s|--system)        SYSTEM="$2";      shift 2 ;;
    -d|--dry-run)       DRY_RUN=true;     shift ;;
    -k|--keep-going)    KEEP_GOING=true;  shift ;;
    -f|--filter)        FILTER="$2";      shift 2 ;;
    --no-build)         NO_BUILD=true;    shift ;;
    --include-checks)   INCLUDE_CHECKS=true; shift ;;
    -h|--help)
      sed -n '2,/^set /p' "$0" | grep '^#' | sed 's/^# \?//'
      exit 0 ;;
    -*) die "Unknown option: $1" ;;
    *)  FLAKE_REF="$1"; shift ;;
  esac
done

[[ -z "$CACHE" ]] && die "No cache specified. Use -c/--cache or set \$ATTIC_CACHE."

# ── Dependency checks ────────────────────────────────────────────────────────
for cmd in nix attic jq; do
  command -v "$cmd" &>/dev/null || die "'$cmd' not found in PATH."
done

# ── Collect installable attribute paths ─────────────────────────────────────
info "Enumerating flake outputs for ${BOLD}${FLAKE_REF}${RESET} (system: ${SYSTEM})…"

SHOW_JSON="$(nix flake show --json --all-systems "$FLAKE_REF" 2>/dev/null)" \
  || die "Failed to run 'nix flake show'. Is '$FLAKE_REF' a valid flake?"

ATTRS=()

collect_system_outputs() {
  local prefix="$1"
  local json_path="$2"
  while IFS= read -r attr; do
    [[ -n "$attr" ]] || continue
    ATTRS+=("${FLAKE_REF}#${attr}")
  done < <(
    echo "$SHOW_JSON" \
    | jq -r --arg sys "$SYSTEM" --arg pfx "$prefix" \
        "${json_path} | .[\$sys] // {} | keys[]? | \"\(\$pfx).\(\$sys).\" + ." \
      2>/dev/null || true
  )
}

# packages.<system>.*
collect_system_outputs "packages"       ".packages"
# devShells.<system>.*
collect_system_outputs "devShells"      ".devShells"
# checks.<system>.* (opt-in)
$INCLUDE_CHECKS && collect_system_outputs "checks" ".checks"
# nixosConfigurations.*.config.system.build.toplevel
while IFS= read -r host; do
  [[ -n "$host" ]] || continue
  ATTRS+=("${FLAKE_REF}#nixosConfigurations.${host}.config.system.build.toplevel")
done < <(echo "$SHOW_JSON" | jq -r '.nixosConfigurations // {} | keys[]?' 2>/dev/null || true)
# homeConfigurations.*.activationPackage
while IFS= read -r name; do
  [[ -n "$name" ]] || continue
  ATTRS+=("${FLAKE_REF}#homeConfigurations.${name}.activationPackage")
done < <(echo "$SHOW_JSON" | jq -r '.homeConfigurations // {} | keys[]?' 2>/dev/null || true)
# legacyPackages.<system>.* — shallow only
collect_system_outputs "legacyPackages" ".legacyPackages"

# Apply --filter
if [[ -n "$FILTER" ]]; then
  FILTERED=()
  for a in "${ATTRS[@]}"; do
    [[ "$a" =~ $FILTER ]] && FILTERED+=("$a")
  done
  ATTRS=("${FILTERED[@]}")
fi

if [[ ${#ATTRS[@]} -eq 0 ]]; then
  warn "No derivations found to build/push. Check your flake outputs and --filter."
  exit 0
fi

info "Found ${BOLD}${#ATTRS[@]}${RESET} output(s) to process."
printf '  %s\n' "${ATTRS[@]}"
echo

# ── Scratch dir for result symlinks ──────────────────────────────────────────
RESULTS_BASE="$(mktemp -d -t attic-push.XXXXXX)"
cleanup() { rm -rf "$RESULTS_BASE"; }
trap cleanup EXIT

# ── Build → push → clean, one attr at a time ─────────────────────────────────
PUSHED=0
FAILED_ATTRS=()
KEEP_GOING_FLAG=()
$KEEP_GOING && KEEP_GOING_FLAG=(--keep-going)

info "Building and pushing ${#ATTRS[@]} output(s) with ${JOBS} job(s)…"
echo

for attr in "${ATTRS[@]}"; do
  # Filesystem-safe slug derived from the attr path
  slug="${attr#*#}"
  slug="${slug//[^a-zA-Z0-9_.-]/-}"

  result_dir="${RESULTS_BASE}/${slug}"
  mkdir -p "$result_dir"

  echo -e "  ${BOLD}→${RESET} $attr"

  if $DRY_RUN; then
    info "  [DRY RUN] Would build and push: $attr"
    rm -rf "$result_dir"
    continue
  fi

  # ── Build ──────────────────────────────────────────────────────────────────
  if $NO_BUILD; then
    mapfile -t paths < <(nix path-info --impure "$attr" 2>/dev/null || true)
    if [[ ${#paths[@]} -eq 0 ]]; then
      warn "  Not realised (skipping): $attr"
      FAILED_ATTRS+=("$attr")
      rm -rf "$result_dir"
      $KEEP_GOING || die "Aborting. Use --keep-going to continue."
      continue
    fi
    idx=0
    for p in "${paths[@]}"; do
      ln -sf "$p" "${result_dir}/result-${idx}"
      (( idx++ )) || true
    done
  else
    if ! nix build "${KEEP_GOING_FLAG[@]}" \
            --out-link "${result_dir}/result" \
            --max-jobs "$JOBS" --impure "$attr" 2>&1; then
      err "  Build failed: $attr"
      FAILED_ATTRS+=("$attr")
      rm -rf "$result_dir"
      $KEEP_GOING || die "Aborting due to build failure. Use --keep-going to continue."
      continue
    fi
  fi

  # ── Push result symlink (attic follows it into the store) ─────────────────
  if attic push "$CACHE" "${result_dir}/result"; then
    ok "  Pushed: $attr"
    (( PUSHED++ )) || true
  else
    err "  Push failed: $attr"
    FAILED_ATTRS+=("$attr")
    $KEEP_GOING || die "Aborting due to push failure. Use --keep-going to continue."
  fi

  # Clean up immediately to free disk space before the next build
  rm -rf "$result_dir"
  echo
done

# ── Summary ──────────────────────────────────────────────────────────────────
echo -e "${BOLD}═══ Summary ═══${RESET}"
echo -e "  Flake:    ${FLAKE_REF}"
echo -e "  Cache:    ${CACHE}"
echo -e "  System:   ${SYSTEM}"
echo -e "  Pushed:   ${PUSHED}"
[[ ${#FAILED_ATTRS[@]} -gt 0 ]] \
  && echo -e "  ${RED}Failed:   ${#FAILED_ATTRS[@]}${RESET}" \
  || echo -e "  Failed:   0"
echo

[[ ${#FAILED_ATTRS[@]} -gt 0 ]] && exit 1 || exit 0
nix-collect-garbage
