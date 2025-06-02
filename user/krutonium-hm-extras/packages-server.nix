{
  config,
  pkgs,
  lib,
  makeDestopItem,
  fetchurl,
  ...
}:
{
  home.packages = [
    pkgs.fastfetch
  ];
}
