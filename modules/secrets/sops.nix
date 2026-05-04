{ ... }:
{
  flake.nixosModules.sops =
    { config, ... }:
    {
      sops = {
        defaultSopsFile = ./secrets.yaml;
        defaultSopsFormat = "yaml";
        age.sshKeyPaths = [
          "/home/krutonium/.ssh/id_ed25519"
          "/etc/ssh/ssh_host_ed25519_key"
        ];
        secrets = {
          github_token = {
            owner = "krutonium";
          };
        };
        templates."nix-access-tokens.conf" = {
          content = ''
            access-tokens = github.com=${config.sops.placeholder."github_token"}
          '';
          owner = "root";
          group = "krutonium";
          mode = "0440";
        };
      };
    };
}
