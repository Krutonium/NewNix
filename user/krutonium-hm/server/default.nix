{ lib, osConfig, ... }:
{
  imports = lib.optionals (osConfig.sys.roles.server == true) [
    ./packages-server.nix
  ];
}
