# modules/nixos/satisfactory.nix
{ self, ... }:
{
  flake.nixosModules.satisfactory =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.services.satisfactory;
      serverDir = "${cfg.dataDir}/SatisfactoryDedicatedServer";
      configDir = "${serverDir}/FactoryGame/Saved/Config/LinuxServer";
    in
    {

      options.services.satisfactory = {
        enable = lib.mkEnableOption "Satisfactory Dedicated Server";
        portForward = {
          enable = lib.mkEnableOption "nftables DNAT port forwarding for Satisfactory";
          destAddr = lib.mkOption {
            type = lib.types.str;
            description = "LAN IP to forward Satisfactory ports to";
            example = "10.0.0.3";
          };
        };
        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/satisfactory";
          description = "Directory to store server data and installation";
        };

        beta = lib.mkOption {
          type = lib.types.enum [
            "public"
            "experimental"
          ];
          default = "public";
          description = "Beta channel to follow";
        };

        address = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
          description = "Bind address";
        };

        maxPlayers = lib.mkOption {
          type = lib.types.ints.positive;
          default = 4;
          description = "Maximum number of players";
        };

        autoPause = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Auto pause when no players are online";
        };

        autoSaveOnDisconnect = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Auto save on player disconnect";
        };

        extraSteamCmdArgs = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Extra arguments passed to steamcmd";
        };
      };

      config = lib.mkIf cfg.enable {
        users.users.satisfactory = {
          home = cfg.dataDir;
          createHome = true;
          isSystemUser = true;
          group = "satisfactory";
        };
        networking.nat.forwardPorts = lib.mkIf cfg.portForward.enable (
          map
            (port: {
              proto = "tcp";
              sourcePort = port;
              destination = "${cfg.portForward.destAddr}:${toString port}";
            })
            [
              27015
              27036
            ]
          ++
            map
              (port: {
                proto = "udp";
                sourcePort = port;
                destination = "${cfg.portForward.destAddr}:${toString port}";
              })
              [
                7777
                15000
                15777
                27015
              ]
          ++ map (port: {
            proto = "udp";
            sourcePort = port;
            destination = "${cfg.portForward.destAddr}:${toString port}";
          }) (lib.range 27031 27036)
        );
        users.groups.satisfactory = { };

        nixpkgs.config.allowUnfree = true;

        networking.firewall = {
          allowedUDPPorts = [
            15777
            15000
            7777
            27015
          ];
          allowedUDPPortRanges = [
            {
              from = 27031;
              to = 27036;
            }
          ];
          allowedTCPPorts = [
            27015
            27036
          ];
        };

        systemd.services.satisfactory = {
          wantedBy = [ "multi-user.target" ];

          preStart = ''
            ${pkgs.steamcmd}/bin/steamcmd \
              +force_install_dir ${serverDir} \
              +login anonymous \
              +app_update 1690800 \
              -beta ${cfg.beta} \
              ${cfg.extraSteamCmdArgs} \
              validate \
              +quit

            ${pkgs.patchelf}/bin/patchelf \
              --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 \
              ${serverDir}/Engine/Binaries/Linux/UnrealServer-Linux-Shipping

            ln -sfv ${cfg.dataDir}/.steam/steam/linux64 ${cfg.dataDir}/.steam/sdk64

            mkdir -p ${configDir}

            ${pkgs.crudini}/bin/crudini --set ${configDir}/Game.ini \
              '/Script/Engine.GameSession' MaxPlayers ${toString cfg.maxPlayers}

            ${pkgs.crudini}/bin/crudini --set ${configDir}/ServerSettings.ini \
              '/Script/FactoryGame.FGServerSubsystem' mAutoPause \
              ${if cfg.autoPause then "True" else "False"}

            ${pkgs.crudini}/bin/crudini --set ${configDir}/ServerSettings.ini \
              '/Script/FactoryGame.FGServerSubsystem' mAutoSaveOnDisconnect \
              ${if cfg.autoSaveOnDisconnect then "True" else "False"}
          '';

          script = ''
            ${serverDir}/Engine/Binaries/Linux/UnrealServer-Linux-Shipping \
              FactoryGame -multihome=${cfg.address}
          '';

          serviceConfig = {
            Restart = "always";
            User = "satisfactory";
            Group = "satisfactory";
            WorkingDirectory = cfg.dataDir;
          };

          environment = {
            LD_LIBRARY_PATH = lib.concatStringsSep ":" [
              "${serverDir}/linux64"
              "${serverDir}/Engine/Binaries/Linux"
              "${serverDir}/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu"
            ];
          };
        };
      };
    };
}
