{
  config,
  lib,
  modulesPath,
  ...
}:
let
  btrs = [
    # Can't do Persist - No Subvol!
    { subvol = "home"; mountPoint = "/home"; }
    { subvol = "nix";  mountPoint = "/nix";  }
    { subvol = "configuration"; mountPoint = "/etc/nixos"; }
    { subvol = "postgres"; mountPoint = "/var/lib/postgresql"; }
    { subvol = "matrix-synapse"; mountPoint = "/var/lib/matrix-synapse"; }
    { subvol = "gitea"; mountPoint = "/var/lib/forgejo"; nodatacow = true; }
    { subvol = "gitea"; mountPoint = "/var/lib/gitea"; nodatacow = true; }
    { subvol = "nextcloud"; mountPoint = "/var/lib/nextcloud"; }
    { subvol = "transmission"; mountPoint = "/transmission"; nodatacow =  true; }
    { subvol = "transmission-db"; mountPoint = "/var/lib/transmission"; nodatacow = true; }
    { subvol = "sshd"; mountPoint = "/etc/ssh"; }
    { subvol = "acme"; mountPoint = "/var/lib/acme"; }
    { subvol = "plex"; mountPoint = "/var/lib/plex"; }
    { subvol = "root"; mountPoint = "/root"; }
    { subvol = "libvirt"; mountPoint = "/var/lib/libvirt"; nodatacow = true; }
    { subvol = "rustdesk"; mountPoint = "/var/lib/private/rustdesk"; }
    { subvol = "www"; mountPoint = "/var/www"; }
    { subvol = "samba"; mountPoint = "/var/lib/samba"; }
  ];
  btrfsUUID = "/dev/disk/by-uuid/a018b12f-6567-4edb-8026-be9292738b4d";
  btrfsFileSystems = builtins.listToAttrs (map (entry: {
    name = entry.mountPoint;
    value = {
      device = btrfsUUID;
      fsType = "btrfs";
      options = [
        "subvol=${entry.subvol}"
        "compress=zstd:8"
      ] ++ (if entry ? nodatacow && entry.nodatacow then [ "nodatacow" ] else []);
    } // (if entry.mountPoint == "/home" then { neededForBoot = true; } else {});
  }) btrs);
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "wl"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.supportedFilesystems = [ "" ];

  fileSystems = {
    "/" = {
      device = "root";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=16G"
        "mode=775"
      ];
    };
    "/persist" = {
      device = btrfsUUID;
      fsType = "btrfs";
      options = [ "compress=zstd:8" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/2604-D641";
      fsType = "vfat";
    };
    "/media" = {
      device = "/dev/disk/by-id/ata-HGST_HDN726060ALE614_K1G6YP2B-part3";
      fsType = "ext4";
    };
    "/media2" = {
       device = "/dev/disk/by-id/ata-WDC_WD60EDAZ-11U78B0_WD-WX92D622XA45-part1";
       fsType = "ext4";
    };
  } // btrfsFileSystems;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
