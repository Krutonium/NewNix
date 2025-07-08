{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.users;
in
{
  config = mkIf (cfg.gryphon == true) {
    users.users.gryphon = {
      isNormalUser = true;
      home = "/media2/fileHost/gryphon";
      uid = 666;
      openssh.authorizedKeys.keys = [

      ];
      extraGroups = [ "nginx" ];
    };
  };
}
