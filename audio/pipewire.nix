{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.audio;
in
{
  config = mkIf (cfg.server == "pipewire") {
    hardware.pulseaudio.enable = false;
    services = {
      pipewire = {
        enable = true;
        package = pkgs.unstable.pipewire;
        wireplumber.enable = true;
        audio.enable = true;
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
}
