{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "gnome") {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          gdm = {
            enable = true;
            wayland = cfg.wayland;
            autoSuspend = cfg.autoSuspend;
          };
        };
        desktopManager = {
          gnome = {
            enable = true;
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
    };
    hardware = {
      opengl = {
        enable = true;
      };
      pulseaudio = mkIf(!cfg.pipewire){
        enable = true;
      };
    };
    programs = {
      xwayland = {
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
