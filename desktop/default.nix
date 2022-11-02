{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.desktop = {
    desktop = mkOption {
      type = types.enum [ "gnome" "kde" "none" ];
      default = "none";
      description = ''
        Your desktop of choice.
      '';
    };
    wayland = mkOption {
     type = types.bool;
     default = true;
     description = ''
       Whether to use Wayland or X11.
     '';
    };
    autoSuspend = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to automatically suspend the system when the lid is closed.
      '';
    };
    pipeWire = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable PipeWire.
      '';
    };
  };
  imports = [ ./gnome.nix ./kde.nix ./none.nix ];
}