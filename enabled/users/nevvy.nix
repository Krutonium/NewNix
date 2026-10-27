{ ... }:
{
  flake.nixosModules.nevvy =
    { ... }:
    {
      users.users.nevvy = {
        isNormalUser = true;
        uid = 1003;
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
