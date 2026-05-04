{ ... }:
{
  flake.nixosModules.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        protontricks.enable = true;
      };
    };
}
