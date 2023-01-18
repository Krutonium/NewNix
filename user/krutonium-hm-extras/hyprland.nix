{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/hypr/displays.conf".text = ''
      monitor=HDMI-A-1, 1920x1080@144, 3840x0, 1
      monitor=DP-1,     1920x1080@165, 1920x0, 1
      monitor=DP-2,     1920x1080@165, 0x0,    1
      monitor=eDP-1,    1920x1080@60,  0x0,     1
    '';
  };
  home.packages = [
    pkgs.waybar
  ];
}

