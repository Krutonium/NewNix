{ ... }:
{
  flake.nixosModules.lact =
    { mv, ... }:
    {
      disabledModules = [ "services/hardware/lact.nix" ];
      imports = [
        "${toString mv.tip.path}/nixos/modules/services/hardware/lact.nix"
      ];
      services.lact = {
        enable = true;
        package = mv.tip.lact;
      };
    };
}
