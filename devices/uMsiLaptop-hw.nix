{ config
, lib
, modulesPath
, ...
}:
let
  btrfsDisk = "/dev/disk/by-uuid/941617ae-329b-477d-9760-09268d5cfeef";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "sd_mod"
    "sr_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      # tmpfs root
      device = "root";
      fsType = "tmpfs";
      options = [
        "defaults"
        "mode=755"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1B37-4FC4";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    "/nix" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "compress=zstd:15"
        "subvol=nix"
      ];
    };
    "/home" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "compress=zstd:15"
        "subvol=home"
      ];
    };
    "/etc/NetworkManager" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "compress=zstd:15"
        "subvol=networkmanager"
      ];
    };
    "/etc/ssh" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "compress=zstd:15"
        "subvol=ssh"
      ];

    };
    "/storage" = {
      device = "/dev/disk/by-uuid/3333f503-a70b-40b9-8037-8c226456bff4";
      fsType = "ext4";
      options = [
        "defaults"
        "nofail"
        "x-gvfs-show"
        "x-gvfs-name=Storage"
      ];
    };
    "/uWebServer" = {
      device = "krutonium@krutonium.ca:/";
      fsType = "sshfs";
      options = [
        "allow_other" # for non-root access
        "default_permissions"
        "idmap=user"
        "_netdev" # requires network to mount
        "x-systemd.automount" # mount on demand
        "uid=1002" # id -a
        "gid=100"
        "max_conns=20" # MOAR THREADS (when needed)
        "IdentityFile=/home/krutonium/.ssh/id_ed25519"
        # Handle connection drops better
        "ServerAliveInterval=2"
        "ServerAliveCountMax=2"
        "reconnect"
        "nofail"
        "x-gvfs-show"
        "x-gvfs-name=uWebServer"
      ];
    };
    "/uServerHost" = {
      device = "root@10.3:/";
      fsType = "sshfs";
      options = [
        "allow_other" # for non-root access
        "default_permissions"
        "idmap=user"
        "_netdev" # requires network to mount
        "x-systemd.automount" # mount on demand
        "uid=1002" # id -a
        "gid=100"
        "max_conns=20" # MOAR THREADS (when needed)
        "IdentityFile=/home/krutonium/.ssh/id_ed25519"
        # Handle connection drops better
        "ServerAliveInterval=2"
        "ServerAliveCountMax=2"
        "reconnect"
        "nofail"
        "x-gvfs-show"
        "x-gvfs-name=uServerHost"
      ];
    };
  };
  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
