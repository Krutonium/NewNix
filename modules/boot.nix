{ ... }:
{
  flake.nixosModules.boot =
    { pkgs, lib, ... }:
    {
      boot = {
        loader = {
          efi = {
            efiSysMountPoint = "/boot";
            canTouchEfiVariables = true; # Let it use the default paths for compat
          };
          systemd-boot = {
            enable = true;
            memtest86.enable = true;
          };
          timeout = 0;

        };
        initrd.systemd = {
          enable = true;
          services.plymouth-start = {
            after = [ "systemd-modules-load.service" ];
            requires = [ "systemd-modules-load.service" ];
          };
        };
      };
      environment.systemPackages = [ pkgs.plymouth ];
      boot.plymouth = {
        enable = true;
        theme = lib.mkForce "bgrt";
      };
    };
}
