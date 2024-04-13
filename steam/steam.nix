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
        extraPkgs = pkgs: [ glxinfo jre8 monado ];
        extraEnv = {
          __NV_PRIME_RENDER_OFFLOAD = 1;
          __GLX_VENDOR_LIBRARY_NAME= "nvidia";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
        };
      }).run
      protonup-qt
      proton-caller
      protontricks
    ];
    services.udev.packages = [ rift_s_udev ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      gamescopeSession = true;
    };
    environment.etc."monado" = {
      source = pkgs.monado;
    };
  };
}
