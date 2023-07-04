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
    ./virtualization
    ./custom-packages
    ./scripts.nix
  ];
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  boot = {
    tmp.cleanOnBoot = true;
    kernel = {
      sysctl = {
        "vm.max_map_count" = 1000000;
      };
    };
    supportedFilesystems = [ "ntfs" ]; #Add explicit NTFS support
  };
  documentation.enable = true;
 # qt.style = "adwaita-dark";
  hardware.enableAllFirmware = true;
  boot.binfmt = {
    emulatedSystems = [ "aarch64-linux" "riscv64-linux" ];
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
      extra-platforms = x86_64-linux i686-linux aarch64-linux riscv64-linux
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
    };
    firewall = {
      enable = true;
    };
    dhcpcd.wait = "background";
    dhcpcd.extraConfig = "noarp";
    #nameservers = [
    #  "8.8.8.8"
    #  "1.1.1.1"
    #  "2001:4860:4860::8888"
    #  "2606:4700:4700::1111"
    #];
    nameservers = [
       "10.0.0.1"
       "1.1.1.1"
       "8.8.8.8"
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
      systemd-udev-settle.enable = true;
    };
  };

  services = {
    fwupd.enable = true;
  };
  programs.noisetorch.enable = true;
  programs.command-not-found.enable = false;
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
    DefaultTimeoutStopSec=10s
  '';
  boot.kernelParams = [ "mitigations=off" ];
  
  nixpkgs.overlays = [(final: prev: {
    mesa-fix = let
      nixpkgs-fix = builtins.fetchTarball {
        url = "https://github.com/nixos/nixpkgs/tarball/19be5ac0119740b050ddcfd8608691ebf65abf9e";
        sha256 = "0z38lf6gq8ciq5nlw9ziryi9j9klhwzz2xims10pgcwllbn3acw7";
      };
    in (import nixpkgs-fix { inherit (pkgs) system; }).mesa;
  } )];
  #hardware.opengl = {
  #  package = pkgs.mesa-fix.drivers;
  #  package32 = pkgs.pkgsi686Linux.mesa-fix.drivers;
  #};

  # DO NOT CHANGE THIS
  system.stateVersion = "22.05";

}
