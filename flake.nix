{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";                       # NixOS release channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";           # NixOS unstable channel
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";              # NixOS hardware channel
    home-manager.url = "github:nix-community/home-manager/release-22.05";   # Home Manager release channel
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
      ];
    };
  };
}