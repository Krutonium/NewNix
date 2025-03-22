#!/usr/bin/env bash
retry() {
    local cmd="$1"
    while true; do
        echo "Running: $cmd"
        eval "$cmd" && break
        echo "Command failed. Retrying in 5 seconds..."
        sleep 5
    done
}

retry "sudo nixos-rebuild switch --flake .#uGamingPC --target-host uGamingPC"
retry "sudo nixos-rebuild switch --flake .#uMsiLaptop --target-host uMsiLaptop"
retry "sudo nixos-rebuild switch --flake .#uServerHost --target-host uServerHost"
retry "sudo nixos-rebuild switch --flake .#uWebServer --target-host uWebServer"
        
