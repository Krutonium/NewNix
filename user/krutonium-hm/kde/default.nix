{ lib, osConfig, ... }:
{
  imports =
    lib.optionals (osConfig.sys.desktop == "kde") [ ./kde.nix ];
}