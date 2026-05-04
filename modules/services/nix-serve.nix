{ ... }:
{
  flake.nixosModules.nix-serve =
    { config, pkgs, ... }:
    {
      sops.secrets.nix_serve_secret = {
        path = "/etc/secrets/nix_secret";
        restartUnits = [ "nix-serve.service" ];
      };

      services.nix-serve = {
        enable = true;
        openFirewall = true;
        secretKeyFile = config.sops.secrets.nix_serve_secret.path;
        package = pkgs.nix-serve-ng;
      };
    };
}