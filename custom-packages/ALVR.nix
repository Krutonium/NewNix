{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.custom;

in
{
  config = mkIf (cfg.alvr == true) {
    let
    alvr = appimageTools.wrapType2 { # or wrapType1
      name = "ALVR";
      src = fetchurl {
        url = "https://github.com/alvr-org/ALVR/releases/download/v20.5.0/ALVR-x86_64.AppImage";
        hash = "sha256-OqTitCeZ6xmWbqYTXp8sDrmVgTNjPZNW0hzUPW++mq4=";
      };
      extraPkgs = pkgs: with pkgs; [ ];
    };
    in
    {
      environment.systemPackages = [ ];
    };
  };
}
