{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11"; # NixOS release channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # NixOS unstable channel
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
  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, deploy-cs, update }@inputs:
    let
      # This is a Generic Block of St00f
      system = "x86_64-linux";
      genericModules = [
        ./common.nix
        {
          nix.registry.nixos.flake = inputs.self;
          environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
          nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
        }
        home-manager.nixosModules.home-manager
        {
          nix.registry.nixos.flake = inputs.self;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          modules = [
            (args: {
              xdg.configFile."nix/inputs/nixpkgs".source = nixpkgs.outPath;
              home.sessionVariables.NIX_PATH = "nixpkgs=${args.config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
            })
          ];
        }
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              deploy-cs = deploy-cs.defaultPackage.x86_64-linux;
              nixpkgs-update = update.defaultPackage.x86_64-linux;
            })
          ];
        })
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
      ];
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
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
