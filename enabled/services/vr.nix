{ ... }:
{
  flake.nixosModules.vr =
    { pkgs, ... }:
    {
      services.wivrn = {
        enable = true;
        openFirewall = true;
        autoStart = true;
        package = (pkgs.wivrn.override { cudaSupport = true; });      };
    };
}
