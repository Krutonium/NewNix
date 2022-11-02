{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.audio = {
    server = mkOption {
      type = types.enum [ "pulseaudio" "pipewire" ];
      default = "pipewire";
      description = ''
        Which Audio Server to use.
      '';
    };
  };
  imports = [ ./pipewire.nix ./pulseaudio.nix ];
}