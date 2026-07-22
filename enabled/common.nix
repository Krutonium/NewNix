{ inputs, self, ... }:
{
  flake.nixosModules.common =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.nixosModules; [
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        inputs.sops-nix.nixosModules.sops
        inputs.simple-cpu-governor.nixosModules.default
        inputs.nix-index-database.nixosModules.default
        inputs.disko.nixosModules.default
        assets
        nix-settings
        scripts
        default-packages
        fonts
        hostKeys
        firefoxNvidiaOffload
      ];
      nixpkgs.overlays = with inputs.self.overlays; [
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.millennium.overlays.default
        inputs.nvidia-patch.overlays.default
        unstable
        master
        InternetRadio2Computercraft
        intel-media-sdk
        hytale-launcher
        discord-canary-vulkan-patch
        arcmenu
        dolphin-emu-git
        dusklight
        hanabi
      ];
      home-manager = {
        extraSpecialArgs = { inherit inputs; };
        useGlobalPkgs = true;
      };
      environment.systemPackages = [
        pkgs.attic-client
        pkgs.hwdata
      ];
      nixpkgs = {
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
          allowUnfreePredicate = _pkg: true;
          allowBroken = true;
          allowBrokenPredicate = _pkg: true;
          allowInsecure = true;
          allowInsecurePredicate = _pkg: true;
          permittedInsecurePackages = [
          ];
        };
      };
      systemd.user.services.pipewire = {
        after = [
          "dbus.service"
          "dbus-broker.service"
        ];
      };
      virtualisation.vmVariant = {
        virtualisation = {
          memorySize = 8192;
          cores = 8;
          diskSize = 20480;
        };
      };
      systemd = {
        tmpfiles.rules =
          let
            username = "krutonium";
          in
          [
            "f+ /var/lib/AccountsService/users/${username}  0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n"
            "L+ /var/lib/AccountsService/icons/${username}  - - - - ${config.assets.profile}"
          ];
        network.wait-online.anyInterface = true;
      };

      services = {
        atd.enable = true;
        irqbalance.enable = true;
        fwupd.enable = true;
      };
      programs = {
        direnv.enable = true;
        fuse = {
          enable = true;
          userAllowOther = true;
        };
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            icu
            openssl
            zlib
            stdenv.cc.cc.lib
            curl
            krb5
            lttng-ust
            libunwind
            fontconfig
            libx11
            libICE
            libSM
            libXext
            libXi
            libXrandr
            libXrender
            libXcursor
            libXfixes
            libXtst
          ];
        };
      };
      environment = {
        localBinInPath = true;
        homeBinInPath = true;
        shellAliases = {
          ls = "${lib.getExe pkgs.eza} --icons --git";
          cat = "${lib.getExe pkgs.bat}";
          top = "${lib.getExe pkgs.btop}";
          neofetch = "${lib.getExe pkgs.hyfetch}";
          please = "eval sudo \$history[1]";
        };
        variables = {
          EDITOR = "nano";
          VISUAL = "nano";
          __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
          OLLAMA_HOST = "http://10.3:11434";
        };
        sessionVariables = {
          #          GBM_BACKEND = "nvidia-drm";
          #          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        };
      };
      security = {
        polkit.enable = true;
        sudo.wheelNeedsPassword = false;
      };
      hardware = {
        enableAllFirmware = true;
        enableAllHardware = true;
        bluetooth.enable = true;
        usb-modeswitch.enable = true;
        steam-hardware.enable = true;
      };
      time = {
        hardwareClockInLocalTime = true;
        timeZone = "America/Toronto";
      };
      documentation.enable = false;
      nixpkgs.hostPlatform = {
        system = "x86_64-linux";
        #gcc.arch = "x86-64-v3"; Does not compile :(
      };
      system.stateVersion = "26.05";
    };
}
