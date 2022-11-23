{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05"; # NixOS release channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # NixOS unstable channel
    nixos-hardware.url = "github:NixOS/nixos-hardware/master"; # NixOS hardware channel
    home-manager.url = "github:nix-community/home-manager/release-22.05"; # Home Manager release channel
    deploy-cs = {
      url = "github:Krutonium/deploy-cs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, deploy-cs }: {
    #############
    # uGamingPC #
    #############
    nixosConfigurations.uGamingPC = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common.nix
        ./devices/uGamingPC.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        }
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              deploy-cs = deploy-cs.defaultPackage.x86_64-linux;
            })
          ];
        })
        ./overlays/overlay.nix
      ] ++ (with nixos-hardware.nixosModules; [
        common-pc
        common-pc-ssd
        common-cpu-amd
      ]);
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };

    ##############
    # uWebServer #
    ##############
    nixosConfigurations.uWebServer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common.nix
        ./devices/uWebServer.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        }
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              deploy-cs = deploy-cs.defaultPackage.x86_64-linux;
            })
          ];
        })
      ] ++ (with nixos-hardware.nixosModules; [
        common-pc
        common-pc-ssd
        common-cpu-intel
      ]);
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };

    #############
    # uHPLaptop #
    #############
    nixosConfigurations.uHPLaptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common.nix
        ./devices/uHPLaptop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        }
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              deploy-cs = deploy-cs.defaultPackage.x86_64-linux;
            })
          ];
        })
      ] ++ (with nixos-hardware.nixosModules; [
        common-pc
        common-pc-ssd
        common-cpu-intel
      ]);
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };

    #############
    # uMsiLaptop #
    #############
    nixosConfigurations.uMsiLaptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common.nix
        ./devices/uMsiLaptop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        }
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (self: super: {
              deploy-cs = deploy-cs.defaultPackage.x86_64-linux;
            })
          ];
        })
      ] ++ (with nixos-hardware.nixosModules; [
        common-pc
        common-pc-ssd
        common-cpu-intel
      ]);
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    };
  };
}
