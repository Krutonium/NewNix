{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;

  hugoTheme = builtins.fetchTarball {
    name = "Hugo-Theme-PaperMod";
    url = https://github.com/adityatelange/hugo-PaperMod/archive/f5c737f.tar.gz;
    sha256 = "0m9vllmp5j33j2ga3cy7zqa5z2wcvh4jph4g6fhch0smqla1sp73";
  };
  script = pkgs.writeShellScript "blog-start"
  ''
    ln -snf ${hugoTheme} themes/PaperMod
    hugo server -D -E -b krutonium.ca -p 1313
  '';
in
{
  config = mkIf (cfg.blog == true) {
    # Temporarily open the Firewall
    networking.firewall.allowedTCPPorts = [ 1313 ];
    systemd.services."blog" = {
        description = "My Blog";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.hugo ];
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
