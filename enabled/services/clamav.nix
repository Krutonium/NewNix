{ ... }:
{
  flake.nixosModules.clamav =
    { config, lib, ... }:
    let
      normalUsers = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
      downloadDirectories = lib.mapAttrsToList (_: user: "${user.home}/Downloads") normalUsers;
    in
    {
      services.clamav = {
        daemon.enable = true;
        scanner = {
          enable = true;
          interval = "Wed *-*-* 03:00:00";
        };
        updater.enable = true;
        fangfrisch.enable = true;
        clamonacc.enable = true;
        daemon.settings = {
          OnAccessPreverntion = true;
          OnAccessIncludePath = downloadDirectories;
        };
        scanner.scanDirectories = [
          "/home"
          "/var/lib"
          "/tmp"
          "/etc"
          "/var/tmp"
        ];
      };
    };
}
