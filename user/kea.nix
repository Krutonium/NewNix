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
  config = mkIf (cfg.kea == true) {
    users.users.kea = {
      isNormalUser = true;
      home = "/home/kea";
      uid = 1001;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZaIK7NUUlJRaxVCnRc3Bq78aVw9LRd2zDNGKQMixuW kea@WARFSTATION"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElh2sqH+6bZWIDBL5haoTn0VPuFmHoROpernmr7Jrao kea@TWIST"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOOQoLq0Ao5GuNSWDbxPuL/qYCTlaLL62BnyM/K+Xlt kea@BOX"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+EnBu0D+Nh20+Hyp90H96p4q5SsMZupHNH71v0NJUt kea@PASCIENCE"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQYEAnii3cGo9zehJKaHx0Z9xwQ2mTVz/TCvoWXeVjQ kea@venus"
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
