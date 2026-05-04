{ inputs, self, ... }:
{
  flake.nixosConfigurations.uServerHost = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      uServerHostModule
      avahi
      boot
      common
      nvidia-legacy
      krutonium
      sops
      ssh
      minecraftServers
      ut99
      nix-serve
    ];
  };

  flake.nixosModules.uServerHostModule =
    { pkgs, config, ... }:
    let
      kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
      btrfsDisk = "/dev/disk/by-label/WorkDisk";
      Hostname = "uServerHost";
    in
    {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelModules = [ "nct6775 " ]; # SuperIO/Temp Sensors.
      networking = {
        hostName = Hostname;
        hostId = "e8501831";
      };

      boot = {
        kernelPackages = kernel;
        kernelParams = [ "mitigations=off" ];
      };
      zramSwap = {
        enable = true;
        priority = 1;
        writebackDevice = "/dev/disk/by-label/swap-root";
      };
      nix = {
        daemonCPUSchedPolicy = "idle";
        settings = {
          cores = 16;
          max-jobs = 16;
          system-features = [ "gccarch-znver1" ];
        };
      };

      minecraftServers.servers = [
        {
          name = "AtM10_Sky";
          java = pkgs.jdk21;
          script = "run.sh";
          enabled = true;
          rconPort = 12370;
          rconPasswordFile = "/servers/rcon.password";
          port = 25570;
        }
        {
          name = "vanilla";
          java = pkgs.jdk21;
          script = "startserver.sh";
          enabled = true;
          rconPort = 12347;
          rconPasswordFile = "/servers/rcon.password";
          port = 25565;
          extraUDPPorts = [ 19132 ]; # Bedrock
        }
        {
          name = "create_chronicles";
          java = pkgs.jdk21;
          script = "run.sh";
          enabled = true;
          rconPort = 12348;
          rconPasswordFile = "/servers/rcon.password";
          port = 25568;
        }
        {
          name = "Hytale";
          java = pkgs.jdk25;
          script = "startserver.sh";
          enabled = true;
          rconPort = 0;
          rconPasswordFile = "/dev/null";
          extraUDPPorts = [ 5520 ];
        }
      ];

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
    };
}
