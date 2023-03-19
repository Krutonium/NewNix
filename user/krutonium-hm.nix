{ config, pkgs, ... }:
{
  imports = [
    ./krutonium-hm-extras/dconf.nix
    ./krutonium-hm-extras/git.nix
    ./krutonium-hm-extras/user-config.nix
    ./krutonium-hm-extras/packages.nix
    ../overlays/overlay.nix
    ./krutonium-hm-extras/terminal.nix
  ];
  programs.home-manager.enable = true;

  # Fixes icons not reloading when switching system.
  targets.genericLinux.enable = true;

  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";
  home.sessionVariables.NIX_PATH = "nixpkgs=${args.config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
  home.stateVersion = "22.05";
}
