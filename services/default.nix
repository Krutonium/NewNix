{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins;
{
  options.sys.services = {
    plex = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Plex Media Server
      '';
    };
    avahi = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Avahi
      '';
    };
    coredns = mkOption {
      type = types.bool;
      default = false;
      description = ''
        CoreDNS
      '';
    };
    samba = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Samba
      '';
    };
    satisfactoryServer = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Satisfactory Server
      '';
    };
    unturnedServer = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Unturned Server
      '';
    };
    ssh = mkOption {
      type = types.bool;
      default = true;
      description = ''
        SSH
      '';
    };
    sshGuard = mkOption {
      type = types.bool;
      default = false;
      description = ''
        SSHGuard
      '';
    };
    synapse = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Synapse
      '';
    };
    nginx = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Nginx
      '';
    };
    gitea = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Gitea
      '';
    };
    torrent = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Torrent Client
      '';
    };
    ddns = mkOption {
      type = types.bool;
      default = false;
      description = ''
        NameCheap Dynamic DNS
      '';
    };
    autoDeploy = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Runs deploy-cs every 2 hours to keep everything up to date.
      '';
    };
    noisetorch = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables NoiseTorch
      '';
    };
    noisetorchDevice = mkOption {
      type = types.string;
      default = "";
      description = ''
        The device it should listen to.
      '';
    };
    sevendaystodie = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Installs and runs the 7 Days to Die Dedicated Server
      '';
    };
    homeAssistant = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Home Assistant
      '';
    };
    nbfc = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Notebook Fan Control
      '';
    };
    cockpit = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Dashboard
      '';
    };
    easydiffusion = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Easy Diffusion!
      '';
    };
    invidious = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Invidious!
      '';
    };
    syncthing = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Syncthing!
      '';
    };
    nextcloud = mkOption {
      type = types.bool;
      default = false;
      description = ''
        NextCloud!
      '';
    };
    postgresql = mkOption {
      type = types.bool;
      default = false;
      description = ''
        PostgreSQL!
      '';
    };
    blog = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Host Blog
      '';
    };
    schedule-updates = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Schedule Update on Odd Days
      '';
    };
  };
  imports = [
    ./plex.nix
    ./avahi.nix
    ./coredns.nix
    ./samba.nix
    ./satisfactory-server.nix
    ./unturned-server.nix
    ./ssh.nix
    ./synapse.nix
    ./nginx.nix
    ./gitea.nix
    ./torrent.nix
    ./ddns.nix
    ./deploy.nix
    ./noisetorch.nix
    ./sevendaystodie.nix
    ./home_assistant.nix
    ./nbfc.nix
    ./cockpit.nix
    ./easy-diffusion.nix
    ./invidious.nix
    ./syncthing.nix
    ./nextcloud.nix
    ./postgresql.nix
    ./blog.nix
    ./update-schedule.nix
  ];
}
