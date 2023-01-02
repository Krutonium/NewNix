{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.virtualization;
in
{
  config = mkIf (cfg.server == "virtd") {
    virtualisation.libvirtd = {
      enable = true;

      onShutdown = "suspend";
      onBoot = "ignore";

      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        ovmf.package = pkgs.OVMFFull;
        swtpm.enable = true;
        runAsRoot = false;
      };
    };

    environment.etc = {
      "ovmf/edk2-x86_64-secure-code.fd" = {
        source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
      };

      "ovmf/edk2-i386-vars.fd" = {
        source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
        mode = "0644";
        user = "libvirtd";
      };
    };
    environment.systemPackages = [ pkgs.swtpm pkgs.virt-manager ];
    users.users.krutonium.extraGroups = [ "libvirtd" ];
  };
}
