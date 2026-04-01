#!/usr/bin/env bash
SOPS_AGE_KEY_FILE=<(ssh-keygen -ef ~/.ssh/id_ed25519 | age-keygen -i /dev/stdin) sops -d ./secrets.yaml
sops ./secrets.yaml
