{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11"; # NixOS release channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # NixOS unstable channel
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # NixOS hardware channel
    home-manager.url = "github:nix-community/home-manager/release-22.11"; # Home Manager release channel
    update = {
      url = "github:ryantm/nixpkgs-update";
    };
    deploy-cs = {
      url = "github:Krutonium/deploy-cs/parallel-build-parallel-deploy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, nixos-hardware, home-manager, deploy-cs, update }@inputs:
    let
      # This is a Generic Block of St00f
      system = "x86_64-linux";
      genericModules = [
        ./common.nix
        {
          # This fixes things that don't use Flakes, but do want to use NixPkgs.
          nix.registry.nixos.flake = inputs.self;
          environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
          nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
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
                overlay-deploy-cs
                overlay-nixpkgs-update
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
        };
      };
      overlay-master = final: prev: {
        master = import nixpkgs-master {
          inherit system;
          config.allowUnfree = true;
        };
      };
      # overlayh for deploy-cs
      overlay-deploy-cs = final: prev: {
        deploy-cs = deploy-cs.defaultPackage.x86_64-linux;
      };
      # overlay for nixpkgs-update
      overlay-nixpkgs-update = final: prev: {
        nixpkgs-update = update.defaultPackage.x86_64-linux;
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
      };
      ##################
      ### uMsiLaptop ###
      ##################
      nixosConfigurations.uMsiLaptop = nixpkgs.lib.nixosSystem {
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
