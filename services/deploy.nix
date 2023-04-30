{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.autoDeploy == true) {
    systemd = {
      services.updateSystems = {
        serviceConfig.Type = "oneshot";
        serviceConfig.User = "krutonium";
        path = with pkgs; [ pkgs.deploy-cs pkgs.nix pkgs.nixos-rebuild pkgs.git pkgs.openssh pkgs.nixpkgs-fmt ];
        script = ''
          cd /home/krutonium/NixOS/
          deploy
        '';
        enable = true;
      };
      timers.updateSystems = {
        wantedBy = [ "timers.target" ];
        partOf = [ "updateSystems.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 00,02,04,06,08,10,12,14,22:00:00"; # Every 2 hours, except when streaming
          Unit = "updateSystems.service";
        };
        enable = true;
      };
    };
  };
}
