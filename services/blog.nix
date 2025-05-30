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
  script = pkgs.writeShellScript "blog-start" ''
    cd /home/krutonium/Blog/
    git pull
    hugo server -D -E -b krutonium.ca -p 1313 --appendPort=false -e production
  '';
in
{
  config = mkIf (cfg.blog == true) {
    systemd.services."blog" = {
      description = "My Blog";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.hugo pkgs.git ];
      serviceConfig = {
        Type = "simple";
        ExecStart = script;
        WorkingDirectory = "/home/krutonium/Blog/";
        Restart = "always";
        RestartSec = "5";
        User = "krutonium";
      };
    };
  };
}
