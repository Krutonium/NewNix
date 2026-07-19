# Drop this anywhere import-tree will pick it up (e.g. alongside your other
# service modules). Runs Overte's official OCI image via
# virtualisation.oci-containers rather than building from source — see the
# options below for why.
{ self, ... }:
{
  flake.nixosModules.overte-server = { config, lib, pkgs, ... }:
    let
      cfg = config.services.overte-server;
    in
    {
      options.services.overte-server = {
        enable = lib.mkEnableOption "the Overte metaverse domain server (run from upstream's OCI image)";

        image = lib.mkOption {
          type = lib.types.str;
          default = "docker.io/overte/overte-server:latest";
          description = "OCI image to run. Multi-arch (amd64/aarch64), published by the Overte project.";
        };

        backend = lib.mkOption {
          type = lib.types.enum [ "podman" "docker" ];
          default = "podman";
          description = ''
            Container backend used to run the image. Podman is rootless-friendly and
            the more idiomatic NixOS default; set this to "docker" if you'd rather
            reuse an existing dockerd on the host.
          '';
        };

        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/overte-server";
          description = ''
            Persistent storage for domain settings, content, and entities.
            Mounted at /root/.local/share/Overte inside the container, matching
            upstream's documented Docker invocation.
          '';
        };

        logDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/log/overte-server";
          description = "Where the container's /var/log is bind-mounted to on the host.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Open the ports Overte needs. Note: upstream's Docker image hardcodes
            these ports internally, so they can't be remapped here without breaking
            connectivity for some clients.
          '';
        };

        extraOptions = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "--memory=4g" ];
          description = "Extra arguments passed straight through to the container backend.";
        };
      };

      config = lib.mkIf cfg.enable {
        virtualisation.podman.enable = lib.mkIf (cfg.backend == "podman") true;
        virtualisation.docker.enable = lib.mkIf (cfg.backend == "docker") true;
        virtualisation.oci-containers.backend = cfg.backend;

        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0750 root root - -"
          "d ${cfg.logDir} 0750 root root - -"
        ];

        virtualisation.oci-containers.containers.overte-server = {
          image = cfg.image;
          autoStart = true;
          ports = [
            "40100-40102:40100-40102/tcp"
            "40100-40102:40100-40102/udp"
            "48000-48006:48000-48006/udp"
          ];
          volumes = [
            "${cfg.dataDir}:/root/.local/share/Overte"
            "${cfg.logDir}:/var/log"
          ];
          extraOptions = cfg.extraOptions;
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPortRanges = [
            { from = 40100; to = 40102; }
          ];
          allowedUDPPortRanges = [
            { from = 40100; to = 40102; }
            { from = 48000; to = 48006; }
          ];
        };
      };
    };
}