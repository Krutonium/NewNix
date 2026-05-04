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
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        inputs.sops-nix.nixosModules.sops
        self.nixosModules.assets
        self.nixosModules.nix-settings
        self.nixosModules.scripts
        self.nixosModules.default-packages
        self.nixosModules.fonts
      ];
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
        inputs.self.overlays.unstable
        inputs.self.overlays.InternetRadio2Computercraft
        inputs.millennium.overlays.default
      ];
      home-manager = {
        extraSpecialArgs = { inherit inputs; };
        useGlobalPkgs = true;
      };
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
      };
      environment = {
        localBinInPath = true;
        homeBinInPath = true;
        shellAliases = {
          ls = "${lib.getExe pkgs.eza} --icons --git";
          cat = "${lib.getExe pkgs.bat}";
          top = "${lib.getExe pkgs.btop}";
          neofetch = "${lib.getExe pkgs.fastfetch}";
        };
        variables = {
          GSK_RENDERER = "gl";
          EDITOR = "nano";
          VISUAL = "nano";
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
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "25.11";
    };
}
