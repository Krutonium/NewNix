{ lib, osConfig, ... }:
{
  imports = lib.optionals (osConfig.sys.desktop == "gnome") [ ./gnome.nix ];
}
