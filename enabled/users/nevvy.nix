{ ... }:
{
  flake.nixosModules.gryphon =
    { ... }:
    {
      users.users.nevvy = {
        isNormalUser = true;
        home = "/home/nevvy/";
        createHome = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOduuppZkxij78BVSmXoCdJbFEJegN9oBvkQsTSipWtv Nevvydrone"
        ];
        extraGroups = [ "users" ];
      };
      users.users.nginx.extraGroups = [ "users" ];
    };
}