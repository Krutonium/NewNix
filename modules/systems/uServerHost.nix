{ inputs, self, ... }:
{
  flake.nixosConfigurations.uServerHost = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      uServerHostModule
      avahi
      boot
      common
      krutonium
      sops
      ssh
      minecraftServers
      minecraftServerData
      ut99
      nix-serve
      root
      zswap
    ];
  };

  flake.nixosModules.uServerHostModule =
    { pkgs, config, ... }:
    let
      kernel = pkgs.linuxPackages_latest;
      btrfsDisk = "/dev/disk/by-label/WorkDisk";
      Hostname = "uServerHost";
    in
    {
      boot.kernelModules = [ "nct6775" ];
      networking = {
        hostName = Hostname;
        hostId = "e8501831";
        networkmanager.enable = true;
      };

      boot = {
        kernelPackages = kernel;
        kernelParams = [ "mitigations=off" ];
      };

      nix = {
        daemonCPUSchedPolicy = "idle";
        settings = {
          cores = 16;
          max-jobs = 16;
          system-features = [ "gccarch-znver1" ];
        };
      };

      hardware = {
        graphics.enable = true;
        cpu.amd.updateMicrocode = true;
        nvidia = {
          powerManagement.enable = true;
          package = kernel.nvidiaPackages.legacy_580;
          prime.offload.enable = false;
          open = false;
          nvidiaSettings = false;
          modesetting.enable = true;
          nvidiaPersistenced = true;
        };
      };
      nixpkgs.config.cudaSupport = true;

      swapDevices = [
        { device = "/dev/disk/by-partuuid/c7fd54ef-b439-4b34-adf1-13e9392c7f3f"; priority = 1; discardPolicy = "both"; }
        { device = "/dev/disk/by-partuuid/54e1603d-4c12-41c8-934b-06c81e4f8499"; priority = 1; discardPolicy = "both"; }
      ];

      fileSystems = {
        "/boot"                      = { device = "/dev/disk/by-label/BOOT";    fsType = "vfat"; };
        "/btrfs"                     = { device = btrfsDisk; fsType = "btrfs";  options = [ "compress=zstd:15" ]; };
        "/home"                      = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=Home" ]; neededForBoot = true; };
        "/servers/starbound"         = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=starbound" ]; };
        "/servers/AtM9"              = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=AtM9" ]; };
        "/servers/AoF7"              = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=AoF7" ]; };
        "/servers/snapshots"         = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=snapshots" ]; };
        "/servers/vanilla"           = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=vanilla" ]; };
        "/servers/AtM10_Sky"         = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=AtM10_Sky" ]; };
        "/servers/create_chronicles" = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=create_chronicles" ]; };
        "/servers/Hytale"            = { device = btrfsDisk; fsType = "btrfs";  options = [ "noatime" "compress=zstd:15" "subvol=Hytale" ]; };
        "/backups"                   = { device = "/dev/disk/by-label/Backups"; fsType = "ext4"; };
        "/"                          = { device = "/dev/disk/by-label/root";    fsType = "ext4"; };
      };
    };
}
