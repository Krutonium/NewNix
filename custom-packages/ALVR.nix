{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.custom;
  alvrPkg = pkgs.appimageTools.wrapType2 {
    # or wrapType1
    name = "ALVR";
    src = fetchurl {
      url = "https://github.com/alvr-org/ALVR/releases/download/v20.5.0/ALVR-x86_64.AppImage";
      sha256 = "sha256:068xmz6rlfc7267zr3zc1z9ndsrpxwvhk0zz8v6y65xzybfks45j";
    };
    extraPkgs = pkgs: with pkgs; [ ];
  };
in
{
  config = mkIf (cfg.alvr == true) {
    environment.systemPackages = [ alvrPkg ];
  };
}
