{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.steam;
in
{
  config = mkIf (cfg.steam == true) {
    environment.systemPackages = with pkgs;[
      steam-run
      (steam.override {
        extraPkgs = pkgs: [ glxinfo jre8 monado ] ++ config.fonts.packages;
        extraEnv = {
          __NV_PRIME_RENDER_OFFLOAD = 1;
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
        };

      }).run
      protonup-qt
      proton-caller
      protontricks
    ];
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
      protontricks.enable = true;
    };
  };
}
