{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.virtualization;
in
{
  config = mkIf (cfg.server == "virtd") {
    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.qemu.swtpm.enable = true;
    virtualisation.libvirtd.qemu.ovmf.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager ];
    users.users.krutonium.extraGroups = [ "libvirtd" ];
  };
}
