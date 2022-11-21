{ config, pkgs, ... }:
{
  imports = [
    ./dconf.nix
    ./git.nix
    ./gnome-config.nix
    ./packages.nix
  ];
  programs.home-manager.enable = true;

  # Fixes icons not reloading when switching system.
  targets.genericLinux.enable = true;

  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";

  home.stateVersion = "22.05";
}
