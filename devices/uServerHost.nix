# This is a machine intended to run Game Servers
# There will be minimal software on it.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  kernel = pkgs.nvidiaFor "580.119.02" pkgs.linuxPackages_6_12;
  btrfsDisk = "/dev/disk/by-label/WorkDisk";
  video = config.boot.kernelPackages.nvidiaPackages.stable;
  Hostname = "uServerHost";
in
{
  imports = [ ./uServerHost-mc.nix ];
  boot.kernelModules = [ "nct6775" ];
  # We want to disable the firewall; the home firewall will be guarding for us.
  networking = {
    hostName = Hostname;
  };
  nixpkgs.config.cudaSupport = true;
  services = {
    ollama = {
      enable = true;
      acceleration = "cuda";
      openFirewall = true;
      host = "0.0.0.0";
      package = pkgs.ollama-cuda.overrideAttrs (
        final: prev: {
          preBuild = ''
            cmake -B build \
              -DCMAKE_SKIP_BUILD_RPATH=ON \
              -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
              -DCMAKE_CUDA_ARCHITECTURES='61' \

            cmake --build build -j $NIX_BUILD_CORES
          '';
        }
      );
    };
    nextjs-ollama-llm-ui = {
      enable = false;
      hostname = "0.0.0.0";
    };
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
  hardware.graphics.enable = true;
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
    "/btrfs" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [ "compress=zstd:15" ];
    };
    "/home" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=Home"
      ];
    };
    "/servers/starbound" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=starbound"
      ];
    };
    "/servers/AtM9" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=AtM9"
      ];
    };
    "servers/AoF7" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=AoF7"
      ];
    };
    "servers/snapshots" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=snapshots"
      ];
    };
    "servers/vanilla" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=vanilla"
      ];
    };
    "servers/AtM10_Sky" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=AtM10_Sky"
      ];
    };
    "servers/create_chronicles" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=create_chronicles"
      ];
    };
    "servers/Hytale" = {
      device = btrfsDisk;
      fsType = "btrfs";
      options = [
        "noatime"
        "compress=zstd:15"
        "subvol=Hytale"
      ];
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

  # Install Packages:
  environment.systemPackages = [
    pkgs.MediaServer
  ];
  networking.firewall.allowedTCPPorts = [ 22 25565 25566 25568 25570 ];
  networking.firewall.allowedUDPPorts = [ 24470 24454 24455 19132 5520 ];
  minecraftServers.servers = [
    {
      name = "AtM10_Sky";
      java = pkgs.jdk21;
      script = "run.sh";
      enabled = true;
      rconPort = 12370;
      rconPasswordFile = "/servers/rcon.password";
    }
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
      enabled = false;
      rconPort = 12346;
      # Read Password from /servers/rcon.password
      rconPasswordFile = "/servers/rcon.password";
    }
    {
      name = "vanilla";
      java = pkgs.jdk21;
      script = "startserver.sh";
      enabled = true;
      rconPort = 12347;
      rconPasswordFile = "/servers/rcon.password";
    }
    {
      name = "create_chronicles";
      java = pkgs.jdk21;
      script = "run.sh";
      enabled = true;
      rconPort = 12348;
      rconPasswordFile = "/servers/rcon.password";
    }
    {
      name = "Hytale";
      java = pkgs.jdk25;
      script = "startserver.sh";
      enabled = true;
      rconPort = 0;
      rconPasswordFile = "/dev/null";
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
