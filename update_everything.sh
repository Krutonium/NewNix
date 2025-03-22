#!/usr/bin/env bash
sudo nixos-rebuild switch --flake .#uGamingPC --target-host uGamingPC
sudo nixos-rebuild switch --flake .#uMsiLaptop --target-host uMsiLaptop
sudo nixos-rebuild switch --flake .#uServerHost --target-host uServerHost
sudo nixos-rebuild switch --flake .#uWebServer --target-host uWebServer
