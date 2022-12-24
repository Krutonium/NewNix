{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.virtualization = {
    server = mkOption {
      type = types.enum [ "virtd" "vbox" "none" ];
      default = "none";
      description = ''
        VM support
      '';
    };
  };
  imports = [ ./virtd.nix ./vbox.nix ./none.nix ];
}
