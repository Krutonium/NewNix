#!/usr/bin/env bash
mkdir -p ~/.config/sops/age
if [ ! -f ~/.config/sops/age/keys.txt ]; then
  nix run nixpkgs#ssh-to-age -- \
    -private-key \
    -i ~/.ssh/id_ed25519 \
    -o ~/.config/sops/age/keys.txt
fi
sops ./secrets.yaml