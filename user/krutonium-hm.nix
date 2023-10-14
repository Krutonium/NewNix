{ config, pkgs, ... }:
{
  imports = [
    ./krutonium-hm-extras/dconf.nix
    ./krutonium-hm-extras/git.nix
    ./krutonium-hm-extras/user-config.nix
    ./krutonium-hm-extras/packages.nix
    ../overlays/overlay.nix
    ./krutonium-hm-extras/terminal.nix
    ./krutonium-hm-extras/xdg.nix
  ];
  programs.home-manager.enable = true;

  # Fixes icons not reloading when switching system.
  targets.genericLinux.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    Host 10.0.0.7
        User admin
        HostKeyAlgorithms +ssh-rsa
    Host 10.0.0.9
        User deck
    '';
  };

  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";
  home.stateVersion = "22.05";
}
