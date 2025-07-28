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
      home = "/home/gryphon/";
      createHome = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJzTUr5S8GiM4p4Tb3xs5BZm9yNf0ExEzi+VBt2VssOQ eddsa-key-20250727"
      ];
      extraGroups = [ "users" ];
    };
    users.users.nginx.extraGroups = [ "users" ];
  };
}
