{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.audio;
in
{
  config = mkIf (cfg.server == "pulseaudio") {
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
}
