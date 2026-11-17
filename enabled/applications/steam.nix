{ ... }:
{
  flake.nixosModules.steam =
    { pkgs, mv, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          extest = mv.tip.extest;
        })
      ];
      programs.steam = {
        enable = true;
        extest.enable = true;
        package = mv.tip.steamWithMillennium;
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
