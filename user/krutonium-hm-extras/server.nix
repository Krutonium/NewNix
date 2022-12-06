{ config, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./server.nix
    ./terminal.nix
  ];
  programs.home-manager.enable = true;

  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";

  home.stateVersion = "22.05";
}
