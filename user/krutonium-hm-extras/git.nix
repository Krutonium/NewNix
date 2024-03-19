{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Krutonium";
    userEmail = "PFCKrutonium@gmail.com";
    lfs.enable = false;
    config = {
      init = {
        defaultBranch = "main";
      };
      push = {
        autoSetupRemote = true;
      };
      merge = {
        ff = true;
      };
    };
  };
}
