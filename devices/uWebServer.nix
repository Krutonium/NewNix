{ config, pkgs, lib, ... }:
let
  kernel = pkgs.linuxPackages_zen;
  Hostname = "uWebServer";
in
{
  system.autoUpgrade.allowReboot = true;
  networking.firewall.allowedTCPPorts = [ 25565 25566 50056 9000 ];
  networking.firewall.allowedUDPPorts = [ 50056 67 68 10578 ];
  # 10578 is Skyrim Together
  networking.hostName = Hostname;
  boot = {
    kernelPackages = kernel;
  };
  zramSwap = {
    enable = true;
    priority = 1;
  };
  boot.tmp.useTmpfs = true;
  imports = [ ./uWebServer-hw.nix ./uWebServer-networking.nix ];
  #services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    extraPackages = [ pkgs.rocm-opencl-icd ];
  };

  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  sys = {
    boot = {
      bootloader = "uefi";
      plymouth_enabled = false;
    };
    desktop = {
      desktop = "none";
      wayland = false;
      displayManager = "none";
    };
    audio = {
      server = "none";
    };
    users = {
      krutonium = true;
      home-manager = false;
      root = true;
      kea = true;
    };
    services = {
      plex = true;
      avahi = true;
      coredns = false;
      samba = true;
      satisfactoryServer = false;
      unturnedServer = false;
      ssh = true;
      sshGuard = true;
      synapse = true;
      gitea = true;
      torrent = true;
      ddns = false;
      nginx = true;
      autoDeploy = false;
      sevendaystodie = false;
      headscale = false;
      tailscale = false;
      tailscaleUseExitNode = false;
      homeAssistant = false;
      cockpit = true;
      easydiffusion = true;
      invidious = false;
      syncthing = false;
    };
    virtualization = {
      server = "virtd";
    };
    minecraft = {
      rubberdragontrain = true;
    };
  };
  #services.cron.systemCronJobs = [
  #  "0 6 * * * root systemctl reboot"
  #];
  virtualisation.docker.enable = true;
  users.users.krutonium.extraGroups = [ "docker" ];
  systemd.services = {
    duckdns = {
      description = "DuckDNS dynamic DNS updater.";
      serviceConfig.Type = "oneshot";
      after = [ "network-online.target" "sys-subsystem-net-devices-enp5s0.device" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.curl ];
      script = ''
        token=$(cat /persist/duckdns_token.txt)
        ipv4=$(curl -s ipv4.icanhazip.com)
        #ipv6=$(curl -s ipv6.icanhazip.com)
        url4=$(echo https://www.duckdns.org/update?domains=krutonium\&token=$token\&ipv4=$ipv4)
        #url6=$(echo https://www.duckdns.org/update?domains=krutonium\&token=$token\&ipv6=$ipv6)
        curl -k -s $url4
        #curl -k -s $url6
      '';
    };
    BetterFanController = {
      description = "Better Fan Controller to control GPU fans";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = "/tmp";
        user = "root";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.BetterFanController ];
      script = ''
        BetterFanController
      '';
      enable = true;
    };
  };

  systemd.timers.duckdns = {
    wantedBy = [ "timers.target" ];
    partOf = [ "duckdns.service" ];
    timerConfig.OnCalendar = [ "*:0/5" ];
  };
}


