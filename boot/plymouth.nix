{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.bootloader == "plymouth_enabled") {
    environment.systemPackages = [ pkgs.plymouth ];
    boot.plymouth.enable = cfg.bootloader;
    boot.plymouth.theme = cfg.plymouth_theme;
  };
}