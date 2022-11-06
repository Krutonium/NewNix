{ config, pkgs, ...}:
let
  kernel = pkgs.linuxPackages;
  Hostname = "uWebServer";
in
{
  boot.kernelPackages = kernel;
  networking.hostName = Hostname;
  imports =  [ ./uWebServer-hw.nix ];
  sys = {
    boot = {
      bootloader = "uefi";
    };
    desktop = {
      desktop = "none";
      wayland = false;
    };
    audio = {
      server = "none";
    };
    users = {
      krutonium = true;
      home-manager = false;
      root = true;
    };
  };
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      stoneblock3 = {
        enable = true;
        serverConfig = {
          server-port = 25565;
          motd = "Kappa";
        };
      };
    };
  };
}