#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash openssh

hosts=(
    10.1
    10.2
    10.3
    10.5
)

nupdate
push-to-attic -c KruCache

successful_hosts=()

for host in "${!pids[@]}"; do
    if wait "${pids[$host]}"; then
        successful_hosts+=("$host")
    else
        echo "$host: failed or offline"
    fi
done

for host in "${successful_hosts[@]}"; do
    ssh -o BatchMode=yes -o ConnectTimeout=10 \
        "$host" \
        'sudo shutdown -r +5' &
done

wait
