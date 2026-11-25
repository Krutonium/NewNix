{ ... }:
{
  flake.nixosModules.steam =
    { pkgs, mv, ... }:
    let
      pkgSource = mv.tip;
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          extest = pkgSource.extest;
        })
      ];
#      disabledModules = [ "programs/steam.nix" ];
#      imports = [
#        "${toString pkgSource.path}/nixos/modules/programs/steam.nix"
#      ];
      programs.steam = {
        enable = true;
        extest.enable = true;
        package = pkgSource.steamWithMillennium;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        extraPackages = with pkgs; [
          hidapi
        ];
        protontricks.enable = true;
      };
    };
}
