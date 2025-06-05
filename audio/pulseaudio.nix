{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.audio;
in
{
  hardware = mkIf (cfg.server == "pulseaudio") {
    pulseaudio.enable = true;
  };
}
