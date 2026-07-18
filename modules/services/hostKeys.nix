# modules/nixos/hostKeys.nix
{ lib, ... }:
{
  flake.nixosModules.hostKeys =
    { lib, config, ... }:
    let
      hosts = {
        uGamingPC = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKoAMeIuHglCBVUSiSPqx1BsNq7sQZ7Y1bRG2y26OgLl";
          sopsSecret = "ssh_host_key_uGamingPC";
          aliases = [
            "10.0.0.2"
            "fd00:beef::2"
          ];
        };
        uWebServer = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnrA9o97fSY1vHxOconNP1ZQpwZRD0sKQSTjhxIfJt2";
          sopsSecret = "ssh_host_key_uWebserver";
          aliases = [
            "10.0.0.1"
            "fd00:beef::1"
            "git.krutonium.ca"
            "krutonium.ca"
          ];
        };
        uMsiLaptop = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVKSuf1To5jXsPl4RMwY1aGAbhP5c6gGShmWjG6apnM";
          sopsSecret = "ssh_host_key_uMsiLaptop";
          aliases = [
            "10.0.0.5"
            "fd00:beef::5"
          ];
        };
        uServerHost = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYSSM1N25CKH8HIEsl49Vrilimzc1C7/S5oZcR37cjY";
          sopsSecret = "ssh_host_key_uServerHost";
          aliases = [
            "10.0.0.3"
            "fd00:beef::3"
          ];
        };
        uSteamDeck = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYSSM1N25CKH8HIEsl49Vrilimzc1C7/S5oZcR37cjY";
          sopsSecret = "ssh_host_key_uServerHost";
          aliases = [
            "10.0.0.9"
            "fd00:beef::9"
          ];
        };
      };

      thisHost = config.networking.hostName;
      thisCfg = hosts.${thisHost} or null;

      allAliases = lib.foldlAttrs (
        acc: _name: cfg:
        acc
        // lib.mapAttrs (alias: address: {
          inherit address;
          publicKey = cfg.publicKey;
        }) (cfg.aliases or { })
      ) { } hosts;
    in
    {
      programs.ssh.knownHosts = lib.foldlAttrs (
        acc: name: cfg:
        acc
        // lib.listToAttrs (
          map (alias: {
            name = alias;
            value = {
              hostNames = [ alias ];
              publicKey = cfg.publicKey;
            };
          }) ([ name ] ++ (cfg.aliases or [ ]))
        )
      ) { } hosts;

      sops.secrets = lib.optionalAttrs (thisCfg != null) {
        ${thisCfg.sopsSecret} = {
          path = "/etc/ssh/ssh_host_ed25519_key";
          owner = "root";
          group = "root";
          mode = "0600";
        };
      };
      services.openssh.hostKeys = lib.optionals (thisCfg != null) [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
}
