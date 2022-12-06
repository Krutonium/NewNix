{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.users;
in
{
  config = mkIf (cfg.krutonium == true) {
    users.users.krutonium = {
      uid = 1002;
      home = "/home/krutonium";
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "docker" "deluge" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp" ];
      hashedPassword = "$6$l5HeZlsZILfJPHoJ$bE95YsS6Xu1kTj9RgPKpd4JblUsoA35UmCrqFdr5N71HNa3T3SA3Nw.RxT4ifqF239DzYECcyZQZQGLCtFb8W/";
    };
    #programs.fish.enable = true;
    #programs.fish.useBabelfish = true;
    programs.zsh.enable = true;
    home-manager.users.krutonium =
      if (cfg.home-manager == true) then
        import ./krutonium-hm.nix
      else
        import ./krutonium-hm-extras/server.nix;
  };
}
