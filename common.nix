{ config, pkgs, outputs, inputs, ... }:
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
    #./builders
  ];
  security.pam.services = {
    gdm-autologin-keyring.text = ''
      auth      optional      ${pkgs.gdm}/lib/security/pam_gdm.so
      auth      optional      ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
    '';
  };
  services.irqbalance.enable = true;
  #xdg.portal.enable = true;
  #xdg.portal.extraPortals = [
  #  pkgs.xdg-desktop-portal-gtk
  #];
  environment.shellAliases = {
    ls = "${pkgs.eza}/bin/eza --icons --git";
  };
  services.system76-scheduler = {
    enable = true;
    settings.processScheduler = {
      pipewireBoost.enable = true;
      enable = true;
    };
    package = pkgs.system76-scheduler;
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="bdi", ATTR{min_ratio}="2", ATTR{max_ratio}="50"
  '';
  security.sudo.wheelNeedsPassword = false;
  services.printing.enable = false;
  services.printing.drivers = with pkgs; [ brlaser ];
  services.ddccontrol.enable = true;
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    MANGOHUD = "1";
    QT_QPA_PLATFORMTHEME = "gnome";
  };
  boot = {
    tmp.cleanOnBoot = true;
    kernel = {
      sysctl = {
        "vm.max_map_count" = 1000000;
        "vm.dirty_ratio" = "25"; # 25% of all memory optionally as write cache
        "kernel.panic" = "60";
        "kernel.perf_event_paranoid" = "1";
        "kernel.kptr_restrict" = "0";
      };
    };
    supportedFilesystems = [ "ntfs" ]; #Add explicit NTFS support
  };
  documentation.enable = true;
  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    usb-modeswitch.enable = true;
  };
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      min-free = 50 * 1000 * 1000 * 1000; # 50GB
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
    };
    #package = pkgs.nix-monitored;
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = x86_64-linux i686-linux aarch64-linux riscv64-linux
    '';
    settings = {
      system-features = [ "i686-linux" "x86_64-linux" "big-parallel" "kvm" ];
    };
  };
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "America/Toronto";
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
      allowUnfreePredicate = (pkg: true);
      permittedInsecurePackages = [
        #"electron-25.9.0"
        "dotnet-sdk-wrapped-6.0.428"
        # ReEvaluate @ 24.05
        # Needed for YouTube Music
      ];
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

  #console = {
  #  earlySetup = false;
  #  packages = with pkgs; [ monocraft ];
  #  font = "${pkgs.monocraft}/share/fonts/truetype/8ah1prg91rd6y6qz0bc18bk045s9l3q0-Monocraft-no-ligatures.ttf";
  #  keyMap = "us";
  #};

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
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };
  programs.command-not-found.enable = false;
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
    DefaultTimeoutStopSec=10s
  '';
  nixpkgs.overlays = [
    (final: prev: {
      mesa-fix =
        let
          nixpkgs-fix = builtins.fetchTarball {
            url = "https://github.com/nixos/nixpkgs/tarball/19be5ac0119740b050ddcfd8608691ebf65abf9e";
            sha256 = "0z38lf6gq8ciq5nlw9ziryi9j9klhwzz2xims10pgcwllbn3acw7";
          };
        in
        (import nixpkgs-fix { inherit (pkgs) system; }).mesa;
    })
  ];
  #hardware.opengl = {
  #  package = pkgs.mesa-fix.drivers;
  #  package32 = pkgs.pkgsi686Linux.mesa-fix.drivers;
  #};

  # DO NOT CHANGE THIS
  system.stateVersion = "23.11";

}
