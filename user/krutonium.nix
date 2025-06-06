{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  users = config.sys.users;
  roles = config.sys.roles;
in
{
  config = mkIf (users.krutonium == true) {
    users.users.krutonium = {
      uid = 1002;
      home = "/home/krutonium";
      isNormalUser = true;
      description = "Krutonium";
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "docker"
        "deluge"
        "adbusers"
        "i2c-dev"
        "gamemode"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp"
      ];
      hashedPassword = "$6$l5HeZlsZILfJPHoJ$bE95YsS6Xu1kTj9RgPKpd4JblUsoA35UmCrqFdr5N71HNa3T3SA3Nw.RxT4ifqF239DzYECcyZQZQGLCtFb8W/";
    };
    programs.fish.enable = true;
    programs.fish.useBabelfish = true;
    home-manager.users.krutonium =
      if roles.desktop == true then
        import ./krutonium-desktop.nix
      else if roles.server == true then
        import ./krutonium-server.nix
      else
        null;
  };
}
