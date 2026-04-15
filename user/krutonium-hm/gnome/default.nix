{ lib, osConfig, ... }:
{
  imports = lib.optionals (osConfig.sys.desktop.desktop == "gnome") [ ./gnome.nix ];
}
