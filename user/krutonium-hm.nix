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
    #./krutonium-hm-extras/fonts.nix Made `W I D E` fonts for some reason, not worth having enabled rn.
  ];
  programs.home-manager.enable = true;

  # Fixes icons not reloading when switching system.
  targets.genericLinux.enable = true;

  programs.ssh = {
    enable = true;
    compression = true;
    userKnownHostsFile = "/dev/null";
    matchBlocks = {
      "deck" = {
        hostname = "10.9";
        user = "deck";
      };
      "uWebServer" = {
        hostname = "10.1";
        user = "krutonium";
      };
    };
    extraConfig = ''
      StrictHostKeyChecking no
    '';
  };

  home.username = "krutonium";
  home.homeDirectory = "/home/krutonium";
  home.sessionVariables.EDITOR = "nano";
  home.sessionVariables.VISUAL = "nano";
  home.stateVersion = "22.05";
}
