{ ... }:
{
  flake.nixosModules.root =
    { ... }:
    {
      users.users.root = {
        isSystemUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGydZMghVpYF+glHje55hN0/00i9nOEA+OP4A/eneXp"
        ];
      };
    };
}
