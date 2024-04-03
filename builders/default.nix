{ config, pkgs, outputs, inputs, ... }:
{
  imports = [
    ./uWebServer.nix
  ];
}