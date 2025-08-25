{ pkgs, ... }:
{

  # THIS IS THE DESKTOP PROFILE

  imports = [
    ./krutonium-hm-extras
  ];
  programs.home-manager.enable = true;

  # Fixes icons not reloading when switching system.
  targets.genericLinux.enable = true;
  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";
  home.sessionVariables.OLLAMA_HOST = "10.0.0.3";
  home.stateVersion = "22.05";
}
