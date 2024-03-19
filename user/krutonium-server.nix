{ config, pkgs, ... }:
{
  imports = [
    ./krutonium-hm-extras/git.nix
    ./krutonium-hm-extras/terminal.nix
    ./krutonium-hm-extras/ssh.nix
    ./krutonium-hm-extras/packages-server.nix
  ];
  programs.home-manager.enable = true;

  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";

  home.stateVersion = "22.05";
}
