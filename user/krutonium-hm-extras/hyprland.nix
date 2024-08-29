{ config, pkgs, ... }:
{
  # Install packages specific to this desktop:
  home.packages = with pkgs; [
    wofi
    kitty
  ];
  wayland.windoManager.hyprland.settings = {
    "monitor" = "DP-1, 1920x1080@165, 3840x0, 1";
    "monitor" = "DP-2, 1920x1080@165, 0x0, 2";
    "monitor" = "DP-3, 1920x1080@165, 1920x0, 3";

    "$terminal" = "kitty";
    "$fileManager" = "dolphin";
    "$browser" = "firefox";
    "$menu" = "wofi --show drun";

    "$mainMod" = "SUPER";
    "$secondaryMod" = "ALT";

    "bind" = "$mainMod, Q, exec, $terminal";
    "bind" = "$mainMod, C, killactive";
  };
}