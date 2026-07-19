{ ... }:
{
  flake.nixosModules.blog =
    { config, pkgs, ... }:
    let
      script = pkgs.writeShellScript "blog-start" ''
        cd /home/krutonium/Blog/
        git pull
        hugo server -D -E -b ${config.networking.domain} -p 1313 --appendPort=false -e production
      '';
    in
    {
      systemd.services."blog" = {
        description = "My Blog";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [
          pkgs.hugo
          pkgs.git
          pkgs.go
        ];
        serviceConfig = {
          Type = "simple";
          ExecStart = script;
          WorkingDirectory = "/home/krutonium/Blog/";
          Restart = "always";
          RestartSec = "5";
          User = "krutonium";
        };
      };
      systemd.timers."blog" = {
        description = "Restart My Blog every hour";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
        };
      };
      services.nginx.virtualHosts = {
        "krutonium.ca" = {
          locations."/".proxyPass = "http://127.0.0.1:1313"; # Hugo
        };
      };
    };
}
