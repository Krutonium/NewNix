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
    { device = "/dev/disk/by-uuid/90083dac-4f03-49f1-bb83-e7dc14eca16a";
      fsType = "ext4";
    };
  #fileSystems."/games" = 
  #  { device = "UUID=3bf2876e-bdcc-45da-ac94-a5bcbf996df8";
  #    fsType = "bcachefs";
  #  };
  fileSystems."/boot" =
    { device = "UUID=48DA-2BEF";
      fsType = "vfat";
    };
  fileSystems."/windows" = 
    { device = "UUID=6023862438DB2AD4";
      fsType = "ntfs";
    };
  fileSystems."/scratch" = 
    { device = "UUID=1CE7761638DB2AD4";
      fsType = "ntfs";
    };
  fileSystems."/uWebServer" =
    {
      device = "krutonium@krutonium.ca:/";
      fsType = "sshfs";
      options =
        [
          "allow_other" # for non-root access
          "default_permissions"
          "idmap=user"
          "_netdev" # requires network to mount
          "x-systemd.automount" # mount on demand
          "uid=1000" # id -a
          "gid=100"
          "max_conns=20" # MOAR THREADS (when needed)
          "IdentityFile=/home/krutonium/.ssh/id_ed25519"
  #        # Handle connection drops better
          "ServerAliveInterval=2"
          "ServerAliveCountMax=2"
          "reconnect"
        ];
    };
  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
