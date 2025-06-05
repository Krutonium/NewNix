{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.steam;
in
{
  config = mkIf (cfg.steam == true) {
    environment.systemPackages = with pkgs; [
      steam-run
      (steam.override {
        extraPkgs =
          _pkgs:
          [
            glxinfo
            jre8
          ]
          ++ config.fonts.packages;
      }).run
      protonup-qt
      proton-caller
      #protontricks
    ];
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        steamtinkerlaunch
      ]
      ;
    };
  };
}
