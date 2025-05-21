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
retry "nupdate"
retry "sudo nixos-rebuild boot --flake .#uGamingPC --target-host 10.2"
retry "sudo nixos-rebuild boot --flake .#uMsiLaptop --target-host 10.4"
retry "sudo nixos-rebuild boot --flake .#uServerHost --target-host 10.3"
retry "sudo nixos-rebuild boot --flake .#uWebServer --target-host 10.1"
#retry 'ssh 10.1 "sudo nix-collect-garbage -d && nix-collect-garbage -d"'
#retry 'ssh 10.2 "sudo nix-collect-garbage -d && nix-collect-garbage -d"'
#retry 'ssh 10.3 "sudo nix-collect-garbage -d && nix-collect-garbage -d"'
#retry 'ssh 10.4 "sudo nix-collect-garbage -d && nix-collect-garbage -d"'
#ssh 10.3 "sudo reboot now"
#ssh 10.1 "sudo reboot now"
#sudo shutdown now

