# This is a machine intended to run Game Servers
# There will be minimal software on it.
{ config, pkgs, lib, inputs, ... }:
let
  kernel = with pkgs; linuxPackages_latest;
  video = config.boot.kernelPackages.nvidiaPackages.stable;
  Hostname = "uServerHost";
in
{
  # We want to disable the firewall; the home firewall will be guarding for us.
  networking = {
    firewall.enable = lib.mkForce false;
    hostName = Hostname;
  };

  boot = {
    kernelPackages = kernel;
    kernelParams = [ "mitigations=off" ];
  };

  # We are going to use a lot of swap space
  zramSwap = {
    enable = true;
    priority = 1000;
  };

  # TODO: Enable after making partitions. This will be a swap partition. There will be one on each disk.
  # swapDevices = [
  #   {
  #     device = "";
  #     priority = 1;
  #     size = 8192;
  #   }
  # ];

  # Compile everything with CPU tuning
  # TODO: Enable after installing system
  #  nixpkgs.hostPlatform = {
  #    gcc.arch = "znver1";
  #    gcc.tune = "znver1";
  #    system = "x86_64-linux";
  #  };

  nix = {
    daemonCPUSchedPolicy = "idle";
    settings = {
      cores = 4;
      max-jobs = 4;
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
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "btrfs";
      options = "noatime,compress=zstd:15,space_cache,autodefrag,";
    };
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
  };


  # At some point, I will need to figure out how to handle automatic updates.
  sys.users.krutonium = true;
  sys.roles.server = true;
  system.stateVersion = lib.mkForce "24.11";
}
