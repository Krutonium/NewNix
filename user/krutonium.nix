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
        "gameserver"
        "minecraft"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp"
      ];
      hashedPassword = "$6$l5HeZlsZILfJPHoJ$bE95YsS6Xu1kTj9RgPKpd4JblUsoA35UmCrqFdr5N71HNa3T3SA3Nw.RxT4ifqF239DzYECcyZQZQGLCtFb8W/";
    };
    programs.fish.enable = true;
    programs.fish.useBabelfish = true;
    home-manager.users.krutonium = {
      imports = [ ./krutonium-hm ];
      programs.home-manager.enable = true;
      # Fixes icons not reloading when switching system.
      targets.genericLinux.enable = true;
      home.username = "krutonium";
      home.homeDirectory = "/home/krutonium";
      home.sessionVariables.EDITOR = "nano";
      home.sessionVariables.VISUAL = "nano";
      home.sessionVariables.OLLAMA_HOST = "10.0.0.3";
      home.stateVersion = "22.05";
    };
  };
}
