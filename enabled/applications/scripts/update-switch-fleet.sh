#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash openssh tmux

set -Eeuo pipefail

hosts=(
    10.1
    10.2
    10.3
    10.5
)

# --- Telegram -----------------------------------------------------------
# All credential handling and the actual send live in telegram-notify.sh;
# see that script for the lookup order (environment, then FLEET_NOTIFY_SOPS,
# then FLEET_NOTIFY_ENV / /run/secrets/fleet-notify).
#
# TELEGRAM_NOTIFY can point at a different copy of the helper; otherwise the
# sibling script is used when running from the repo, falling back to PATH.
notify_cmd="${TELEGRAM_NOTIFY:-}"
if [ -z "$notify_cmd" ]; then
    script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    if [ -x "$script_dir/telegram-notify.sh" ]; then
        notify_cmd="$script_dir/telegram-notify.sh"
    else
        notify_cmd=telegram-notify
    fi
fi

# Never let a notification failure kill the run
notify() {
    "$notify_cmd" "$@" || true
}

tmpdir=$(mktemp -d)
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT
trap 'notify "❌ Fleet update aborted (line $LINENO): $BASH_COMMAND"' ERR

# --- Start --------------------------------------------------------------
notify "🚀 Fleet update starting: ${hosts[*]}"
notify "Updating Flake..."
nupdate
notify "Doing Builds..."
push-to-attic -c KruCache

session="fleet-nboot-$$"

# Per-host runner script so we don't fight tmux/bash quoting
for host in "${hosts[@]}"; do
    cat > "$tmpdir/$host.sh" <<EOF
#!/usr/bin/env bash
ssh -o BatchMode=yes -o ConnectTimeout=10 "$host" 'nboot' 2>&1 | tee "$tmpdir/$host.log"
echo \${PIPESTATUS[0]} > "$tmpdir/$host.status"
tmux wait-for -S "done-$host"
EOF
    chmod +x "$tmpdir/$host.sh"
done

# Build the tmux session: first host as the initial pane, rest as splits
tmux new-session -d -s "$session" -n nboot "$tmpdir/${hosts[0]}.sh"
for host in "${hosts[@]:1}"; do
    tmux split-window -t "$session" "$tmpdir/$host.sh"
    tmux select-layout -t "$session" tiled
done
tmux select-layout -t "$session" tiled

# Attach so you can watch it live; script blocks here until you detach or it finishes
tmux attach -t "$session" || true

# Whether or not you stayed attached, wait for every host to actually signal done
for host in "${hosts[@]}"; do
    tmux wait-for "done-$host" 2>/dev/null || true
done
tmux kill-session -t "$session" 2>/dev/null || true

# --- Collect nboot results ---------------------------------------------
declare -a successful_hosts=()
declare -A result=()
for host in "${hosts[@]}"; do
    status=$(cat "$tmpdir/$host.status" 2>/dev/null || echo 1)
    if [ "$status" -eq 0 ]; then
        successful_hosts+=("$host")
        result[$host]="nboot ok"
    else
        echo "$host: failed or offline"
        result[$host]="nboot FAILED (exit $status)"
        tail_log=$(tail -n 15 "$tmpdir/$host.log" 2>/dev/null || echo "(no output, host likely offline)")
        notify "⚠️ $host: nboot failed (exit $status)
$tail_log"
    fi
done

# --- Schedule reboots only on successful hosts -------------------------
for host in "${successful_hosts[@]}"; do
    (
        if ssh -o BatchMode=yes -o ConnectTimeout=10 \
            "$host" \
            'sudo shutdown -r 02:00'; then
            echo ok > "$tmpdir/$host.reboot"
        else
            echo fail > "$tmpdir/$host.reboot"
        fi
    ) &
done
wait

for host in "${successful_hosts[@]}"; do
    if [ "$(cat "$tmpdir/$host.reboot" 2>/dev/null)" = "ok" ]; then
        result[$host]="nboot ok, reboot scheduled 02:00"
    else
        result[$host]="nboot ok, reboot scheduling FAILED"
    fi
done

# --- Summary ------------------------------------------------------------
summary="Fleet update finished:"
failures=0
for host in "${hosts[@]}"; do
    case "${result[$host]}" in
        *FAILED*) icon="❌"; failures=$((failures + 1)) ;;
        *)        icon="✅" ;;
    esac
    summary+=$'\n'"$icon $host: ${result[$host]}"
done

if [ "$failures" -eq 0 ]; then
    notify "🎉 $summary"
else
    notify "⚠️ $summary"
fi
