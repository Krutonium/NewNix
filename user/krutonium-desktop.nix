{ pkgs, ... }:
{

  # THIS IS THE DESKTOP PROFILE

  imports = [
    ./krutonium-hm-extras/dconf.nix
    ./krutonium-hm-extras/git.nix
    ./krutonium-hm-extras/user-config.nix
    ./krutonium-hm-extras/packages-desktop.nix
    ./krutonium-hm-extras/terminal.nix
    ./krutonium-hm-extras/xdg.nix
    ./krutonium-hm-extras/ssh.nix
    ./krutonium-hm-extras/firefox.nix
    ./krutonium-hm-extras/stylix.nix
    ./krutonium-hm-extras/dynamic-shortcuts.nix
    # ./krutonium-hm-extras/hyprland.nix
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
