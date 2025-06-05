{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.virtualization;
in
{
  config = mkIf (cfg.server == "vmware") {
    nixpkgs.config.allowUnfree = true;
    virtualisation.vmware.host.enable = true;
  };
}
