# This is a machine intended to run Game Servers
# There will be minimal software on it.
{ config, pkgs, lib, inputs, ... }:
let
  kernel = with pkgs; linuxPackages;
  btrfsDisk = "/dev/disk/by-label/WorkDisk";
  video = config.boot.kernelPackages.nvidiaPackages.stable;
  Hostname = "uServerHost";
in
{
  imports = [ ./uServerHost-mc.nix ];

  # We want to disable the firewall; the home firewall will be guarding for us.
  networking = {
    firewall.enable = lib.mkForce false;
    hostName = Hostname;
  };

  boot = {
    kernelPackages = kernel;
    kernelParams = [ "mitigations=off" ];
    initrd.systemd.enable = true;
  };

  # We are going to use a lot of swap space
  zramSwap = {
    enable = true;
    priority = 1000;
  };

  # TODO: Enable after making partitions. This will be a swap partition. There will be one on each disk.
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap-root";
      priority = 1;
    }
    {
      device = "/dev/disk/by-label/swap-work";
      priority = 1;
    }
  ];

  nix = {
    daemonCPUSchedPolicy = "idle";
    settings = {
      cores = 16;
      max-jobs = 16;
      system-features = [ "gccarch-znver1" ];
    };
  };
  # Configure nvidia Driver - Closed Source version
  hardware.nvidia = {
    package = video;
    powerManagement = {
      enable = true;
    };
    prime.offload.enable = false;
    open = false;
    nvidiaSettings = false;
    modesetting.enable = true;
    nvidiaPersistenced = true;
  };

  # Filesystems:
  # We will be using ext4 for the root filesystem
  # We will be using btrfs for the /home filesystem
  # We will have a swap partition on each disk

  #TODO: Dummy UUIDs
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
    "/home" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd:15" "subvol=Home" ];
    };
    "/servers/AtM9" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd:15" "subvol=AtM9" ];
    };
    "servers/AoF7" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd:15" "subvol=AoF7" ];
    };
    "/backups" = {
      device = "/dev/disk/by-label/Backups";
      fsType = "ext4";
    };
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
  };

  minecraftServers.servers = [
    {
      name = "AtM9";
      java = pkgs.jdk21;
      script = "startserver.sh";
      enabled = false;
      rconPort = 12345;
      rconPasswordFile = "/servers/rcon.password";
    }
    {
      name = "AoF7";
      java = pkgs.jdk21;
      script = "startserver.sh";
      enabled = true;
      rconPort = 12346;
      # Read Password from /servers/rcon.password
      rconPasswordFile = "/servers/rcon.password";
    }
  ];
  services = {
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="30:9c:23:d3:06:fd", NAME="WAN"
    '';
  };
  # At some point, I will need to figure out how to handle automatic updates.
  sys.users.krutonium = true;
  sys.roles.server = true;
  sys.boot.plymouth_enabled = false;
  system.stateVersion = lib.mkForce "24.11";
}
