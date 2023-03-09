{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.noisetorch == true) {
    #Run the service and also configure the correct device.
    systemd.services.noisetorch = {
        serviceConfig.Type = "oneshot";
        serviceConfig.User = "krutonium";
        path = with pkgs; [ pkgs.noisetorch ];
        script = ''
            noisetorch -s ${cfg.noisetorchDevice} -i -o
        '';
        enable = true;
      };
  };
}