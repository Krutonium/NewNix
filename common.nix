{ config, pkgs, ... }:
{
  imports = [
    ./defaultPackages.nix
    ./boot
    ./audio
    ./desktop
    ./user
    ./services
    ./minecraft
    ./steam
  ];
  boot = {
    cleanTmpDir = true;
  };
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      system-features = [ "i686-linux" "x86_64-linux" "big-parallel" ];
    };
  };
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "America/Toronto";
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (pkg: true);
    };
  };
  networking = {
    networkmanager = {
      enable = true;
      insertNameservers = [ "99.248.154.165" "2607:fea8:7a40:f10:428d:5cff:fe54:8996" ];
    };
    tempAddresses = "disabled";
    firewall = {
      enable = true;
    };
    dhcpcd.wait = "background";
    dhcpcd.extraConfig = "noarp";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2606:4700:4700::1111"
    ];
  };
  i18n = {
    defaultLocale = "en_CA.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  systemd = {
    enableEmergencyMode = false;
    network = {
      wait-online = {
        anyInterface = true;
      };
    };
    services = {
      systemd-udev-settle.enable = false;
    };
  };

  services = {
    fwupd.enable = true;
  };

  # DO NOT CHANGE THIS
  system.stateVersion = "22.05";

}
