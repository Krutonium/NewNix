{ config, pkgs, ... }:
let

  sshr = pkgs.writeShellScriptBin "sshr" ''
    ssh $@
    until !!; do sleep 5 ; done
  '';

in
{
  environment.systemPackages = [ sshr ];
}
