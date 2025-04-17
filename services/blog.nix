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

  hugoTheme = builtins.fetchTarball {
    name = "Hugo-Theme-PaperMod";
    url = "https://github.com/adityatelange/hugo-PaperMod/archive/3e53621.tar.gz";
    sha256 = "00hl085y8bial70jf7xnfg995qs140y96ycgmv8a9r06hsfx1zqf";
  };
  script = pkgs.writeShellScript "blog-start" ''
    cd /home/krutonium/Blog/
    git pull
    ln -snf ${hugoTheme} themes/PaperMod
    hugo server -D -E -b krutonium.ca -p 1313 --appendPort=false -e production
  '';
in
{
  config = mkIf (cfg.blog == true) {
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
