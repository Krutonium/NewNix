{ lib, osConfig, ... }:
{
  imports = lib.optionals (osConfig.sys.roles.desktop == true) [
    ./dynamic-shortcuts.nix
    ./firefox.nix
    ./packages-desktop.nix
    ./screenshot-uploader.nix
    ./user-config.nix
  ];
}
