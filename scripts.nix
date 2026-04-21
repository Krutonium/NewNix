{ pkgs, lib, ... }:
let
  # Helper script to retry SSH connections
  sshr = pkgs.writeShellScriptBin "sshr" ''
    ssh $@
    until !!; do sleep 5 ; done
  '';

  # Update nix-index database from GitHub
  updateindex = pkgs.writeShellScriptBin "updateindex" ''
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    wget -N https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux -O files
    echo Update Complete.
  '';

  # Show what packages depend on a given package
  why-installed = pkgs.writeShellScriptBin "why-installed" ''
    nix-store --query --referrers $(nix-instantiate '<nixpkgs>' -A $1)
  '';

  # Search for where a package is referenced in the config
  where-installed = pkgs.writeShellScriptBin "where-installed" ''
    nix eval --json "/home/krutonium/NixOS/.#nixosConfigurations.$(hostname).options.environment.systemPackages.files" | jq -r ".[]" | xargs rg $1
  '';

  # Run a program using Zink OpenGL driver
  zink = pkgs.writeShellScriptBin "zink" ''
    MESA_LOADER_DRIVER_OVERRIDE=zink $@
  '';

  # Helper script for common git operations
  common_git = pkgs.writeShellScriptBin "common_git" ''
    set -e
    cd ~/NixOS

    # Stash changes if necessary
    git diff --quiet || git stash save "Pre Pull" --include-untracked

    # Check if there are uncommitted changes to commit and push
    if ! git diff --cached --quiet || ! git diff --quiet; then
      git add .
      git commit -m "Auto-commit before pull" || true
      git push || true
    fi

    # Check for new changes to pull
    if git fetch && ! git diff --quiet HEAD..origin/$(git rev-parse --abbrev-ref HEAD); then
      git pull --rebase || true
    fi

    # Attempt to reapply stashed changes if there were any
    git stash list | grep -q "Pre Pull" && git stash pop || true
  '';

  # Clean up old nix generations
  garbage_collect = pkgs.writeShellScriptBin "garbage_collect" ''
    # sudo nix-collect-garbage --delete-older-than 7d --log-format bar-with-logs
    # nix-collect-garbage --delete-older-than 7d --log-format bar-with-logs
    nh clean all
  '';

  # Update flake inputs
  update = pkgs.writeShellScriptBin "nupdate" ''
    set -e
    ${common_git}/bin/common_git
    cd ~/NixOS
    nix flake update --commit-lock-file || true
    git push || true
  '';

  # Rebuild and switch to new configuration
  switch = pkgs.writeShellScriptBin "nswitch" ''
    set -e
    ${common_git}/bin/common_git
    cd ~/NixOS
    # sudo nixos-rebuild --flake .#$(uname -n) switch
    nh os switch .
    # ${garbage_collect}/bin/garbage_collect
  '';

  # Rebuild configuration for next boot
  boot = pkgs.writeShellScriptBin "nboot" ''
    set -e
    ${common_git}/bin/common_git
    cd ~/NixOS
    # sudo nixos-rebuild --flake .#$(uname -n) boot
    nh os boot .
    # ${garbage_collect}/bin/garbage_collect
  '';

  # Commit and push changes to git
  commit = pkgs.writeShellScriptBin "ncommit" ''
    set -e
    cd ~/NixOS
    git add .
    git commit || true
    git pull || true
    git push || true
    git pull || true
    git push || true
  '';

  # Update git remote URL
  relinkrepo = pkgs.writeShellScriptBin "relinkrepo" ''
    cd ~/NixOS
    git remote set-url origin forgejo@git.krutonium.ca:Krutonium/NixOS.git
  '';

  # GitHub CLI explain command wrapper
  explain = pkgs.writeShellScriptBin "explain" ''
    ${pkgs.unstable.gh}/bin/gh explain "$@"
  '';

  # GitHub CLI suggest command wrapper
  help = pkgs.writeShellScriptBin "help" ''
    ${pkgs.unstable.gh}/bin/gh suggest "$@"
  '';
  zink-run = pkgs.writeShellScriptBin "zink-run" ''
    env __GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink "$@"
  '';

  transcode-vr = pkgs.writeShellScriptBin "transcode-vr" ''
    set -euo pipefail

    usage() {
      cat >&2 <<EOF
    Usage: transcode-vr [--gpu] [-b <mbps>] [-f <fps>] <input> <output>

      --gpu        Hardware-accelerated decode/encode (NVENC → VideoToolbox → VAAPI → CPU).
      -b <mbps>    Target bitrate in Mbps for CBR mode (default: quality-based).
      -f <fps>     Output framerate (default: 24).
      <input>      Source video file.
      <output>     Output .mp4 path.

    Examples:
      transcode-vr input.mkv output.mp4
      transcode-vr --gpu -b 8 -f 30 input.mkv output.mp4
    EOF
      exit 1
    }

    # ─── parse args ─────────────────────────────────────────────────────────────
    USE_GPU=0
    MBPS=""
    FPS="24"
    POSITIONAL=()

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --gpu)     USE_GPU=1; shift ;;
        -b)        [[ $# -ge 2 ]] || { echo "Error: -b requires a value." >&2; usage; }
                   MBPS="$2"; shift 2 ;;
        -f)        [[ $# -ge 2 ]] || { echo "Error: -f requires a value." >&2; usage; }
                   FPS="$2"; shift 2 ;;
        -h|--help) usage ;;
        --)        shift; POSITIONAL+=("$@"); break ;;
        -*)        echo "Error: unknown option '$1'" >&2; usage ;;
        *)         POSITIONAL+=("$1"); shift ;;
      esac
    done

    # ─── input guards ───────────────────────────────────────────────────────────
    [[ ''${#POSITIONAL[@]} -ge 1 ]] || { echo "Error: missing <input>."  >&2; usage; }
    [[ ''${#POSITIONAL[@]} -ge 2 ]] || { echo "Error: missing <output>." >&2; usage; }

    INPUT="''${POSITIONAL[0]}"
    OUTPUT="''${POSITIONAL[1]}"

    [[ -e "$INPUT" ]]  || { echo "Error: file not found: '$INPUT'"             >&2; exit 1; }
    [[ -f "$INPUT" ]]  || { echo "Error: not a regular file: '$INPUT'"         >&2; exit 1; }
    [[ -r "$INPUT" ]]  || { echo "Error: file not readable: '$INPUT'"          >&2; exit 1; }

    OUTDIR="$(dirname "$OUTPUT")"
    [[ -d "$OUTDIR" ]] || { echo "Error: output dir does not exist: '$OUTDIR'" >&2; exit 1; }
    [[ -w "$OUTDIR" ]] || { echo "Error: output dir not writable: '$OUTDIR'"   >&2; exit 1; }

    [[ -n "$MBPS" ]] && {
      [[ "$MBPS" =~ ^[0-9]+([.][0-9]+)?$ ]] || { echo "Error: -b must be a number (e.g. 8 or 2.5)." >&2; exit 1; }
    }
    [[ "$FPS" =~ ^[0-9]+([.][0-9]+)?$ ]] || { echo "Error: -f must be a number (e.g. 24 or 29.97)." >&2; exit 1; }

    # ─── GPU detection ──────────────────────────────────────────────────────────
    HWACCEL=""
    VCODEC="libx264"
    DECODE_FLAGS=()

    detect_gpu() {
      local hwaccels encoders
      hwaccels=$(${pkgs.ffmpeg-full}/bin/ffmpeg -hide_banner -hwaccels 2>/dev/null)
      encoders=$(${pkgs.ffmpeg-full}/bin/ffmpeg -hide_banner -encoders 2>/dev/null)

      if echo "$hwaccels" | grep -q "cuda" && echo "$encoders" | grep -q "h264_nvenc"; then
        echo "GPU: NVENC (CUDA)" >&2
        HWACCEL="cuda"
        VCODEC="h264_nvenc"
        DECODE_FLAGS=(-hwaccel cuda)

      elif echo "$hwaccels" | grep -q "videotoolbox" && echo "$encoders" | grep -q "h264_videotoolbox"; then
        echo "GPU: VideoToolbox (Apple)" >&2
        HWACCEL="videotoolbox"
        VCODEC="h264_videotoolbox"
        DECODE_FLAGS=(-hwaccel videotoolbox)

      elif echo "$hwaccels" | grep -q "vaapi" && echo "$encoders" | grep -q "h264_vaapi"; then
        echo "GPU: VAAPI" >&2
        HWACCEL="vaapi"
        VCODEC="h264_vaapi"
        local vaapi_dev="/dev/dri/renderD128"
        if [[ -e "$vaapi_dev" ]]; then
          DECODE_FLAGS=(-vaapi_device "$vaapi_dev" -hwaccel vaapi -hwaccel_output_format vaapi)
        else
          DECODE_FLAGS=(-hwaccel vaapi)
        fi

      else
        echo "GPU: none found — using CPU (libx264)" >&2
        USE_GPU=0
      fi
    }

    [[ $USE_GPU -eq 1 ]] && detect_gpu

    # ─── quality flags ──────────────────────────────────────────────────────────
    if [[ -n "$MBPS" ]]; then
      BPS="$(echo "$MBPS * 1000000 / 1" | ${pkgs.bc}/bin/bc)"
      BUFSIZE="$(echo "$MBPS * 2000000 / 1" | ${pkgs.bc}/bin/bc)"
      case "$VCODEC" in
        libx264)           ENCODE_FLAGS=(-b:v "''${BPS}" -maxrate "''${BPS}" -bufsize "''${BUFSIZE}" -preset veryslow -tune animation) ;;
        h264_nvenc)        ENCODE_FLAGS=(-rc cbr -b:v "''${BPS}" -maxrate "''${BPS}" -bufsize "''${BUFSIZE}" -preset p7 -tune hq) ;;
        h264_videotoolbox) ENCODE_FLAGS=(-b:v "''${BPS}" -maxrate "''${BPS}" -bufsize "''${BUFSIZE}" -allow_sw 1) ;;
        h264_vaapi)        ENCODE_FLAGS=(-b:v "''${BPS}" -maxrate "''${BPS}" -bufsize "''${BUFSIZE}") ;;
      esac
    else
      case "$VCODEC" in
        libx264)           ENCODE_FLAGS=(-crf 18 -preset veryslow -tune animation) ;;
        h264_nvenc)        ENCODE_FLAGS=(-rc vbr -cq 18 -preset p7 -tune hq -b:v 0) ;;
        h264_videotoolbox) ENCODE_FLAGS=(-q:v 65 -allow_sw 1) ;;
        h264_vaapi)        ENCODE_FLAGS=(-global_quality 18 -compression_level 0) ;;
      esac
    fi

    # ─── filter graph ───────────────────────────────────────────────────────────
    if [[ "$HWACCEL" == "vaapi" ]]; then
      FILTER="fps=''${FPS},scale_vaapi=w='min(1280,iw)':h=-2"
    else
      FILTER="fps=''${FPS},scale=w='min(1280,iw)':h=-2"
    fi

    # ─── encode ─────────────────────────────────────────────────────────────────
    echo "Encoding: $VCODEC | GPU=$USE_GPU | fps=''${FPS} | bitrate=''${MBPS:-quality-based}" >&2

    ${pkgs.ffmpeg-full}/bin/ffmpeg -y \
      "''${DECODE_FLAGS[@]}" \
      -i "$INPUT" \
      -vf "$FILTER" \
      -c:v "$VCODEC" "''${ENCODE_FLAGS[@]}" \
      -c:a aac -b:a 320k \
      -movflags +faststart \
      "$OUTPUT"

    echo "Done → $OUTPUT" >&2
  '';
  reboot-fw = pkgs.writeShellScriptBin "reboot-fw" "sudo systemctl reboot --firmware-setup";
  find-desktop = pkgs.writeShellScriptBin "find-desktop" ''
    nix run github:Krutonium/FindTheDesktop -- $@
  '';
  keep-newer = pkgs.writeShellScriptBin "keep-newer" ''
    BASE="$1"
    OURS="$2"
    THEIRS="$3"

    # Get commit timestamps
    OURS_TIME=$(git log -1 --format=%ct -- "$OURS" 2>/dev/null || echo 0)
    THEIRS_TIME=$(git log -1 --format=%ct -- "$THEIRS" 2>/dev/null || echo 0)

    if [ "$THEIRS_TIME" -gt "$OURS_TIME" ]; then
      cp "$THEIRS" "$OURS"
    fi
    exit 0
  '';

  updateKnownHosts = pkgs.writeShellScriptBin "updateKnownHosts" ''
    ${pkgs.gnugrep}/bin/grep "^Host " ~/.ssh/config | ${pkgs.gnugrep}/bin/grep -v '\*' | ${pkgs.gawk}/bin/awk '{print $2}' | while read host; do
      hostname=$(${pkgs.gnugrep}/bin/grep -A5 "^Host $host$" ~/.ssh/config | ${pkgs.gnugrep}/bin/grep "HostName" | ${pkgs.gawk}/bin/awk '{print $2}')
      target="''${hostname:-$host}"
      echo "Scanning $host (''${target})..."
      keys=$(${pkgs.openssh}/bin/ssh-keyscan "$target" 2>/dev/null)
      if [ -z "$keys" ]; then
        echo "  -> Failed to reach $target, skipping."
        continue
      fi
      ${pkgs.coreutils}/bin/touch ~/.ssh/known_hosts
      if ${pkgs.openssh}/bin/ssh-keygen -F "$target" -f ~/.ssh/known_hosts > /dev/null 2>&1; then
        echo "  -> Already present, skipping."
      else
        echo "$keys" >> ~/.ssh/known_hosts
        echo "  -> Added."
      fi
    done
  '';
updateCache = pkgs.writeShellScriptBin "updateCache" ''
  set -euo pipefail

  export PATH="${pkgs.nix}/bin:${pkgs.git}/bin:$PATH"

  FLAKE_DIR="/home/krutonium/NixOS-repo"
  STORE_DIR="/home/krutonium/store"

  cd "$FLAKE_DIR"

  git pull --rebase
  nix flake update

  nix build .# \
    --store "$STORE_DIR" \
    --print-out-paths | while read -r path; do
      nix store sign \
        --store "$STORE_DIR" \
        --key-file "/etc/secrets/nix_secret" \
        "$path"
    done

  if git diff --quiet flake.lock; then
    echo "No lockfile changes."
  else
    git add flake.lock
    git commit -m "chore: auto-update flake.lock $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    git push
  fi

  echo "Done."
'';

in
{
  environment.systemPackages = [
    zink-run
    sshr
    updateindex
    why-installed
    where-installed
    pkgs.jq
    pkgs.git
    zink
    update
    switch
    boot
    commit
    garbage_collect
    relinkrepo
    explain
    help
    transcode-vr
    reboot-fw
    find-desktop
    updateKnownHosts
    updateCache
  ];
}
