{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.teamspeak-server == true) {
    services.teamspeak3 = {
      enable = true;
      openFirewall = true;
      openFirewallServerQuery = true;
      dataDir = "/media/TeamSpeak";
    };
  };
}
