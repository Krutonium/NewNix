{ pkgs, config, lib, ... }:
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
    ssh = mkOption {
      type = types.bool;
      default = trtue;
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
  };
  imports = [
    ./plex.nix
    ./avahi.nix
    ./coredns.nix
    ./samba.nix
    ./satisfactory-server.nix
    ./ssh.nix
  ];
}