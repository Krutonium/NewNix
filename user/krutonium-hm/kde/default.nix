{ lib, osConfig, ... }:
{
  imports =
    lib.optionals (osConfig.sys.desktop.desktop == "kde") [ ./kde.nix ];
}