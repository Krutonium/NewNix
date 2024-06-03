{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # NixOS release channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # NixOS unstable channel
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # NixOS hardware channel
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05"; # Home Manager release channel
      inputs.nixpkgs.follows = "nixpkgs";
    };
    update = {
      url = "github:ryantm/nixpkgs-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fan-controller = {
      url = "github:Krutonium/BetterFanController";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      # inputs.nixpkgs.follows = "nixpkgs"; NUR does not.
    };
    bcachefs-tools_.url = "github:koverstreet/bcachefs-tools";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, nixos-hardware, home-manager, update, nix-monitored, nixd, fan-controller, nur, bcachefs-tools_, ... }@inputs:
    let
      # This is a Generic Block of St00f
      system = "x86_64-linux";
      genericModules = [
        ./common.nix
        {
          # This fixes things that don't use Flakes, but do want to use NixPkgs.
          nix.registry.nixos.flake = inputs.self;
          environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
          nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ];
        }
        home-manager.nixosModules.home-manager
        {
          nix.registry.nixos.flake = inputs.self;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }

        # Make sure you add Overlays here
        ({ config, pkgs, ... }:
          {
            nixpkgs.overlays =
              [
                overlay-unstable
                overlay-master
                overlay-nixpkgs-update
                overlay-monitored
                nixd.overlays.default
                overlay-fanController
                nur.overlay
                overlay-bcachefs
              ];
          }
        )
      ];
      # Overlays
      # nixpkgs-unstable
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          config.nvidia.acceptLicense = true;
        };
      };

      overlay-bcachefs = final: prev: {
        bcachefs-tools = bcachefs-tools_.packages.bcachefs-tools;
      };

      # nixpkgs-master
      overlay-master = final: prev: {
        master = import nixpkgs-master {
          inherit system;
          config.allowUnfree = true;
          config.nvidia.acceptLicense = true;
        };
      };
      # overlay for nixpkgs-update
      overlay-nixpkgs-update = final: prev: {
        nixpkgs-update = update.defaultPackage.x86_64-linux;
      };
      # Fan Controller for AMD Devices
      overlay-fanController = self: super: {
        BetterFanController = fan-controller.defaultPackage.x86_64-linux;
      };
      overlay-monitored = self: super: {
        nixos-rebuild = super.nixos-rebuild.override {
          nix = self.nix-monitored;
        };
        nix-direnv = super.nix-direnv.override {
          nix = self.nix-monitored;
        };
        nix-monitored = inputs.nix-monitored.packages.${self.system}.default.override self;
      };
    in
    {
      ##################
      ### uWebServer ###
      ##################
      nixosConfigurations.uWebServer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = genericModules ++ (with nixos-hardware.nixosModules; [
          common-pc
          common-pc-ssd
          common-cpu-intel
        ]) ++ [ ./devices/uWebServer.nix ];
      };
      #################
      ### uGamingPC ###
      #################
      nixosConfigurations.uGamingPC = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = genericModules ++ (with nixos-hardware.nixosModules; [
          common-pc
          common-pc-ssd
          common-cpu-amd
        ]) ++ [ ./devices/uGamingPC.nix ];
        specialArgs.channels = { inherit nixpkgs nixpkgs-unstable; };
      };
      ##################
      ### uMsiLaptop ###
      ##################
      nixosConfigurations.uMsiLaptop = nixpkgs.lib.nixosSystem {
        #deploy#https://github.com/Skulltrail192/One-Core-API-Binaries/archive/refs/heads/master.zip
        inherit system;
        modules = genericModules ++ (with nixos-hardware.nixosModules; [
          common-pc
          common-pc-ssd
          common-pc-laptop
          common-cpu-intel
        ]) ++ [ ./devices/uMsiLaptop.nix ];
      };
      #################
      ### uHPLaptop ###
      #################
      nixosConfigurations.uHPLaptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = genericModules ++ (with nixos-hardware.nixosModules; [
          common-pc
          common-pc-ssd
          common-pc-laptop
          common-cpu-intel
        ]) ++ [ ./devices/uHPLaptop.nix ];
      };
      ###################
      ### uMacBookPro ###
      ###################
      nixosConfigurations.uMacBookPro = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = genericModules ++ (with nixos-hardware.nixosModules; [
          common-pc
          common-pc-ssd
          common-pc-laptop
          common-cpu-intel
        ]) ++ [ ./devices/uMacBookPro.nix ];
      };
    };
}
