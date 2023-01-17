{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "hyprland") {
    imports = [ hyprland.nixosModules.default ];
  };
}