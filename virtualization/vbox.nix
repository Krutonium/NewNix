{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.virtualization;
in
{
  config = mkIf (cfg.server == "vbox") {
    nixpkgs.config.allowUnfree = true;
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;
    users.extraGroups.vboxusers.members = [ "krutonium" ];
  };
}
