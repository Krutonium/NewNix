# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" =
    {
      device = "root";
      fsType = "tmpfs";
      options = [ "defaults" "size=16G" "mode=775" ];
    };

  fileSystems."/persist" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/2604-D641";
      fsType = "vfat";
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/etc/nixos" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=configuration" ];
    };

  fileSystems."/var/lib/postgresql" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=postgres" "nodatacow" ];
    };

  fileSystems."/var/lib/matrix-synapse" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=matrix-synapse" ];
    };

  fileSystems."/var/lib/gitea" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=gitea" ];
    };

  fileSystems."/var/lib/nextcloud" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=nextcloud" ];
    };

  fileSystems."/transmission" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=transmission" "nodatacow" ];
    };

  fileSystems."/etc/ssh" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=sshd" ];
    };

  fileSystems."/var/lib/acme" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=acme" ];
    };

  fileSystems."/var/lib/plex" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=plex" ];
    };

  fileSystems."/root" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/var/lib/transmission" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=transmission-db" ];
    };
  fileSystems."/var/lib/libvirt" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=libvirt" "nodatacow" ];
    };


  fileSystems."/media" =
    {
      device = "/dev/disk/by-id/ata-HGST_HDN726060ALE614_K1G6YP2B-part3";
      fsType = "ext4";
    };

  fileSystems."/media2" =
    {
      device = "/dev/disk/by-id/ata-WDC_WD60EDAZ-11U78B0_WD-WX92D622XA45-part1";
      fsType = "ext4";
    };

  fileSystems."/var/lib/jellyfin" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=jellyfin" ];
    };

  fileSystems."/var/www" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=www" ];
    };

  fileSystems."/var/lib/softether" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=softether" ];
    };
  fileSystems."/var/lib/samba" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=samba" ];
    };
  fileSystems."/srv" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=gameserver" ];
    };
  fileSystems."/etc/headscale" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=headscale" ];
    };
  fileSystems."/var/lib/headscale" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=headscale" ];
    };
  fileSystems."/var/lib/tailscale" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=tailscale" ];
    };
  fileSystems."/var/lib/hass" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=homeAssistant" ];
    };
  #fileSystems."/tmp" =
  #  {
  #    device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
  #    fsType = "btrfs";
  #    options = [ "subvol=tmp" ];
  #  };
  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
