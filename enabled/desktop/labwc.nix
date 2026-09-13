{ ... }:
{
  flake.nixosModules.labwc =
    { pkgs, ... }:
    {
      programs.labwc.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      environment.systemPackages = [ pkgs.waybar pkgs.foot];
    };
}
