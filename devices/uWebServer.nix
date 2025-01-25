{ config, pkgs, lib, inputs, ... }:
let
  kernel = pkgs.linuxPackages_6_11;
  #kernel = config.boot.zfs.package.latestCompatibleLinuxPackages;
  Hostname = "uWebServer";
in
{
  networking.firewall.allowedTCPPorts = [ 25565 25566 50056 9000 ];
  networking.firewall.allowedUDPPorts = [ 50056 67 68 10578 ];
  networking.domain = "krutonium.ca";
  # 10578 is Skyrim Together
  networking.hostName = Hostname;
  boot = {
    kernelPackages = kernel;
  };
  zramSwap = {
    enable = true;
    priority = 1;
  };
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd intel-compute-runtime intel-media-sdk ];
  boot.tmp.useTmpfs = true;
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" "mitigations=off" ];
  boot.initrd.availableKernelModules = [ "amdgpu" "vendor-reset" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ vendor-reset ];
  imports = [ ./uWebServer-hw.nix ./uWebServer-networking.nix ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    #extraPackages = [ pkgs.rocmPackages.rocm-opencl-icd ];
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
      root = true;
      kea = true;
    };
    roles = {
      server = true;
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
      homeAssistant = false;
      cockpit = true;
      easydiffusion = false;
      invidious = false;
      syncthing = false;
      nextcloud = true;
      blog = true;
      schedule-updates = true;
    };
    virtualization = {
      server = "virtd";
      windows = false;
    };
    minecraft = {
      rubberdragontrain = false;
      gryphon = true;
    };
  };
  #services.cron.systemCronJobs = [
  #  "0 6 * * * root systemctl reboot"
  #];
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      daemon.settings = {
        data-root = "/media2/docker";
      };
    };
    oci-containers = {
      backend = "docker";
      containers."restream" = {
        autoStart = true;
        image = "datarhei/restreamer:vaapi-latest";
        ports = [ "1233:8080" "1234:8181" "1935:1935" ];
        volumes = [ "/dev/dri:/dev/dri" "/persist/restream/config:/core/config" "/persist/restream/data:/core/data" ];
        extraOptions = [ "--privileged" ];
      };
    };
  };
  services.ollama = {
    enable = true;
  };
  nixpkgs.config.rocmSupport = true;
  users.users.krutonium.extraGroups = [ "docker" ];
  systemd.services = {
    duckdns = {
      description = "DuckDNS dynamic DNS updater.";
      serviceConfig.Type = "oneshot";
      after = [ "network-online.target" "sys-subsystem-net-devices-WAN.device" ];
      requires = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.curl pkgs.coreutils ];
      script = ''
        sleep 10;
        # Sleep 10 seconds to allow things to properly settle
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
        Type = "simple";
        WorkingDirectory = "/tmp";
        User = "root";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.BetterFanController ];
      script = ''
        BetterFanController
      '';
      enable = true;
    };
    InternetRadio2Computercraft = {
      description = "Stream Internet Radio for Computercraft";
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/tmp";
        User = "krutonium";
        Restart = "always";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.InternetRadio2Computercraft pkgs.ffmpeg_7-full ];
      script = ''
        InternetRadio2Computercraft
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


