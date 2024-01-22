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
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];
  networking.hostId = "ad53f8bc";
  fileSystems."/" = 
    { device = "UUID=840ac9a3-566b-4a3d-ac6a-f963e95e0413";
      fsType = "ext4";
    };
  fileSystems."/home" =
    { device = "UUID=6d699d8d-364b-40d6-aa55-6e66453828eb";
      fsType = "btrfs";
      options = [ "compress=zstd:15" ];
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4809-BB3C";
      fsType = "vfat";
    };
  #fileSystems."/uWebServer" =
  #  {
  #    device = "krutonium@krutonium.ca:/";
  #    fsType = "sshfs";
  #    options =
  #      [
  #        "allow_other" # for non-root access
  #        "default_permissions"
  #        "idmap=user"
  #        "_netdev" # requires network to mount
  #        "x-systemd.automount" # mount on demand
  #        "uid=1000" # id -a
  #        "gid=100"
  #        "compression=yes"      # Compression should be fine given thehost machine
  #        "max_conns=20" # MOAR THREADS (when needed)
  #        "IdentityFile=/home/krutonium/.ssh/id_ed25519"
  #        # Handle connection drops better
  #        "ServerAliveInterval=2"
  #        "ServerAliveCountMax=2"
  #        "reconnect"
  #      ];
  #  };
  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
