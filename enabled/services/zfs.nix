{ ... }:
{
  flake.nixosModules.zfs-support = { ... }: {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
    services.zfs.autoScrub.enable = true;
    services.zfs.trim.enable = true; # important since you have SSDs in the mix
  };
}