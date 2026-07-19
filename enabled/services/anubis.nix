{ ... }:
{
  flake.nixosModules.anubis =
    { config, lib, ... }:
    {
      key = "krutonium/nixosModules/anubis"; # allow merges from multiple imports

      sops.secrets.anubis_ed25519_key = {
        group = "anubis-access";
        mode = "0440";
      };

      services.anubis.defaultOptions.settings.ED25519_PRIVATE_KEY_HEX_FILE =
        config.sops.secrets.anubis_ed25519_key.path;
    };
}
