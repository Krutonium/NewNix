{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.desktop = {
    desktop = mkOption {
      type = types.enum [ "gnome" "kde" "none" "pantheon" "budgie" "labwc" ];
      default = "none";
      description = ''
        Your desktop of choice.
      '';
    };
    displayManager = mkOption {
      type = types.enum [ "gdm" "lightdm" ];
      default = "lightdm";
      description = ''
        The Login/Display manager you want to use
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
    nvidia = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If we need to do nVidia shit
      '';
    };
  };
  imports = [ ./gnome.nix ./kde.nix ./pantheon.nix ./none.nix ./budgie.nix ./labwc.nix ./lightdm.nix ./gdm.nix ];
}
