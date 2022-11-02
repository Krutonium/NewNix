{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "kde") {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          sddm = {
            enable = true;
          };
        };
        desktopManager = {
          plasma5 = {
            enable = true;
          };
        };
      };
      pipewire = mkIf(cfg.pipewire){
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse = {
          enable = true;
        };
        jack = {
          enable = true;
        };
      };
    };
    hardware = {
      opengl = {
        enable = true;
      };
      pulseaudio = mkIf(!cfg.pipewire){
        enable = true;
      };
    };
    security = {
      rtkit = {
        enable = true;
      };
    };
  };
}