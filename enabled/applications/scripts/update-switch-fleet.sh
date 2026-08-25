#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash openssh tmux

set -euo pipefail

hosts=(
    10.1
    10.2
    10.3
    10.5
)

nupdate
push-to-attic -c KruCache

tmpdir=$(mktemp -d)
session="fleet-nboot-$$"

# Per-host runner script so we don't fight tmux/bash quoting
for host in "${hosts[@]}"; do
    cat > "$tmpdir/$host.sh" <<EOF
#!/usr/bin/env bash
ssh -o BatchMode=yes -o ConnectTimeout=10 "$host" 'nboot'
echo \$? > "$tmpdir/$host.status"
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

# Collect results
declare -a successful_hosts=()
for host in "${hosts[@]}"; do
    status=$(cat "$tmpdir/$host.status" 2>/dev/null || echo 1)
    if [ "$status" -eq 0 ]; then
        successful_hosts+=("$host")
    else
        echo "$host: failed or offline"
    fi
done
rm -rf "$tmpdir"

# Schedule reboots only on successful hosts
for host in "${successful_hosts[@]}"; do
    ssh -o BatchMode=yes -o ConnectTimeout=10 \
        "$host" \
        'sudo shutdown -r 02:00' &
done
wait
