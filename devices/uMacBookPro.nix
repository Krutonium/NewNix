{ config, pkgs, ... }:
let
  kernel = pkgs.linuxPackages_latest;
  Hostname = "uMacBookPro";
in
{
  networking.hostName = Hostname;
  hardware.opengl.enable = true;
  mports = [ ./uMacBookPro-hw.nix ];
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "pantheon";
    };
    audio = {
      server = "pipewire";
    };
    users = {
      krutonium = true;
      home-manager = true;
      root = true;
    };
    services = {
      avahi = true;
      ssh = true;
    };
    steam = {
      steam = true;
    };
  };
}