{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.desktop = {
    desktop = mkOption {
      type = types.enum [ "gnome" "kde" "hyprland" "none" ];
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
    nvidia = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If we need to do nVidia shit
      '';
    };
  };
  imports = [ ./gnome.nix ./kde.nix ./hyprland.nix ./none.nix ];
}
