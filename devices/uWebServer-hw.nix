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
  boot.supportedFilesystems = [ "zfs" ];
 
  fileSystems."/" =
    {
      device = "root";
      fsType = "tmpfs";
      options = [ "defaults" "size=16G" "mode=775" ];
    };
  networking.hostId = "28c77632";
  filesystems."/media2/Gryphon" =
    {
      device = "/media2/Gryphon.zfs";
      fsType = "zfs";
    };
  services.zfs.autoSnapshot = {
    enable = true;
    daily = 4;
    hourly = 8;
    weekly = 1;
    monthly = 1;
    frequent = 4;
  };
  fileSystems."/persist" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "compress=zstd:8" ];
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
      options = [ "subvol=home" "compress=zstd:8" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd:8" ];
    };

  fileSystems."/etc/nixos" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=configuration" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/postgresql" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=postgres" "nodatacow" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/matrix-synapse" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=matrix-synapse" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/gitea" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=gitea" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/nextcloud" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=nextcloud" "compress=zstd:8" ];
    };

  fileSystems."/transmission" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=transmission" "nodatacow" "compress=zstd:8" ];
    };

  fileSystems."/etc/ssh" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=sshd" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/acme" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=acme" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/plex" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=plex" "compress=zstd:8" ];
    };

  fileSystems."/root" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/transmission" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=transmission-db" "compress=zstd:8" ];
    };
  fileSystems."/var/lib/libvirt" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=libvirt" "nodatacow" "compress=zstd:8" ];
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
      options = [ "subvol=jellyfin" "compress=zstd:8" ];
    };

  fileSystems."/var/www" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=www" "compress=zstd:8" ];
    };

  fileSystems."/var/lib/softether" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=softether" "compress=zstd:8" ];
    };
  fileSystems."/var/lib/samba" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=samba" "compress=zstd:8" ];
    };
  fileSystems."/srv" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=gameserver" "compress=zstd:8" ];
    };
  fileSystems."/etc/headscale" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=headscale" "compress=zstd:8" ];
    };
  fileSystems."/var/lib/headscale" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=headscale" "compress=zstd:8" ];
    };
  fileSystems."/var/lib/tailscale" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=tailscale" "compress=zstd:8" ];
    };
  fileSystems."/var/lib/hass" =
    {
      device = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
      fsType = "btrfs";
      options = [ "subvol=homeAssistant" "compress=zstd:8" ];
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
