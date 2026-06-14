{ ... }:
{
  flake.nixosModules.nix-settings =
    { config, lib, ... }:
    {
      nix = {
        settings = {
          require-sigs = false;
          auto-optimise-store = true;
          trusted-users = [ "@wheel" ];
          min-free = 50 * 1000 * 1000 * 1000;
          download-buffer-size = 524288000;
          builders-use-substitutes = true;
          connect-timeout = 2;
          download-attempts = 3;
          system-features = [
            "i686-linux"
            "x86_64-linux"
            "big-parallel"
            "kvm"
          ];
          substituters = [
            "https://cache.nixos-cuda.org"
            "https://attic.xuyh0120.win/lantian"
            "https://cache.krutonium.ca/KruCache"
          ];
          trusted-public-keys = [
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "KruCache:0iLixzkqYP6YOGr3yyBbmI31wV7shAiGgr0GbpSKnvQ="
          ];
          fallback = true;
        };
        registry.unstable.to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          ref = "nixos-unstable";
        };
        gc = {
          automatic = true;
          options = "--delete-older-than 3d";
          dates = "weekly";
        };
        extraOptions = ''
          experimental-features = nix-command flakes
          extra-platforms = x86_64-linux i686-linux
          !include ${config.sops.templates."nix-access-tokens.conf".path}
        '';
        distributedBuilds = lib.mkDefault false;
        buildMachines = [
          {
            hostName = "uWebServer";
            system = "x86_64-linux";
            protocol = "ssh";
            sshUser = "krutonium"; # optional if same username
            maxJobs = 2;
            cores = 2;
            speedFactor = 1;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            systems = [
              "x86_64-linux"
              "i686-linux"
            ];
          }
          {
            hostName = "uGamingPC";
            system = "x86_64-linux";
            protocol = "ssh";
            sshUser = "krutonium"; # optional if same username
            maxJobs = 4;
            cores = 16;
            speedFactor = 10;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            systems = [
              "x86_64-linux"
              "i686-linux"
            ];
          }
          {
            hostName = "uServerHost";
            system = "x86_64-linux";
            protocol = "ssh";
            sshUser = "krutonium"; # optional if same username
            maxJobs = 16;
            speedFactor = 6;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
            systems = [
              "x86_64-linux"
              "i686-linux"
            ];
          }
        ];
      };
    };
}
