{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
  startup = pkgs.writeShellScriptBin "startup"''
    export LIBVA_DRIVER_NAME=nvidia
    export XDG_SESSION_TYPE=wayland
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_NO_HARDWARE_CURSORS=1
    Hyprland
  '';
in
{
  config = mkIf (cfg.desktop == "gnome") {
    programs.hyprland = {
      enable = true;
      nvidiaPatches = true;
    };
    environment.systemPackages = [ pkgs.kitty startup ];
    hardware.opengl.enable = true;
    services.xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.gtk.enable = true;
      };
    };
  };
}
