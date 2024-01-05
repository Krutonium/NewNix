{ config, pkgs, lib, ... }:
let
  #kernel = pkgs.linuxPackages_zen;
  Hostname = "uSteamDeck";
in
{
  #boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  boot.loader.grub.gfxmodeEfi = "1280x800";
  boot.loader.grub.gfxpayloadEfi = "keep";
  imports = [ ./uSteamDeck-hw.nix ];
  swapDevices = [
    {
      device = "/swap";
      size = 8192;
      priority = 0;
    }
  ];
  zramSwap = {
    enable = true;
    priority = 1;
  };
  programs.steam.enable = true;
  #jovian = {
  #  steam = {
  #    enable = true;
  #    autoStart = true;
  #    desktopSession = "gnome";
  #    user = "krutonium";
  #  };
  #  decky-loader.enable = true;
  #  devices = {
  #    steamdeck = {
  #      enable = true; #I am a SteamDeck
  #      enableGyroDsuService = true;
  #    };
  #  };
  #};
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = true;
    };
    desktop = {
      desktop = "gnome";
      wayland = true;
      displayManager = "none";
    };
    audio = {
      server = "pipewire";
    };
    users = {
      krutonium = true;
      home-manager = false;
      root = true;
    };
    services = {
      avahi = true;
      ssh = true;
    };
  };
}
