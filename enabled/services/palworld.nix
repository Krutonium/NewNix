# modules/nixos/palworld.nix
{ ... }:
{
  flake.nixosModules.palworld =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.services.palworld;

      serverDir = "${cfg.dataDir}/PalServer";
      configDir = "${serverDir}/Pal/Saved/Config/LinuxServer";
      settingsFile = "${configDir}/PalWorldSettings.ini";

      bool = b: if b then "True" else "False";

      # Escape a value for use inside a quoted Unreal ini string.
      iniString = value: "\"${lib.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] value}\"";

      generatedSettings = {
        ServerName = iniString cfg.serverName;
        ServerDescription = iniString cfg.serverDescription;
        ServerPlayerMaxNum = toString cfg.maxPlayers;
        PublicPort = toString cfg.port;
        RCONEnabled = bool cfg.rcon.enable;
        RCONPort = toString cfg.rcon.port;
        RESTAPIEnabled = bool cfg.restApi.enable;
        RESTAPIPort = toString cfg.restApi.port;
      }
      // cfg.settings;

      settingLine = lib.concatStringsSep "," (
        lib.mapAttrsToList (name: value: "${name}=${value}") generatedSettings
      );

      launchArgs = [
        "-port=${toString cfg.port}"
        "-players=${toString cfg.maxPlayers}"
      ]
      ++ lib.optional cfg.publicLobby "-publiclobby"
      ++ lib.optional (cfg.publicIP != null) "-publicip=${cfg.publicIP}"
      ++ cfg.extraArgs;
    in
    {
      options.services.palworld = {
        enable = lib.mkEnableOption "Palworld Dedicated Server";

        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/servers/palworld";
          description = "Directory used for the SteamCMD install and Palworld save data.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 8211;
          description = "UDP game port (-port and PublicPort).";
        };

        queryPort = lib.mkOption {
          type = lib.types.port;
          default = 27015;
          description = "UDP Steam query port used by the community server browser.";
        };

        maxPlayers = lib.mkOption {
          type = lib.types.ints.positive;
          default = 32;
          description = "Maximum number of players (ServerPlayerMaxNum).";
        };

        serverName = lib.mkOption {
          type = lib.types.str;
          default = "Palworld Server";
          description = "Name shown in the server browser.";
        };

        serverDescription = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Description shown in the server browser.";
        };

        serverPasswordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            Optional file containing the password players must enter to join.
            The file is read at service start, so it can point at a SOPS secret.
          '';
        };

        adminPasswordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            Optional file containing the in-game admin password.
            The file is read at service start, so it can point at a SOPS secret.
          '';
        };

        publicLobby = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "List the server as a community server (-publiclobby).";
        };

        publicIP = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Explicit public IP for community servers (-publicip).";
        };

        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            ExpRate = "2.000000";
            bIsPvP = "False";
            DeathPenalty = "ItemAndEquipment";
          };
          description = ''
            Extra PalWorldSettings.ini OptionSettings entries, as raw Unreal ini
            values. String values must include their own quotes, e.g.
            { ServerName = "\"My Server\""; }.
          '';
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "-useperfthreads"
            "-NoAsyncLoadingThread"
            "-UseMultithreadForDS"
          ];
          description = "Extra arguments passed to PalServer.sh.";
        };

        rcon = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the Palworld RCON interface.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 25575;
            description = "RCON TCP port. Not opened in the firewall by default.";
          };
        };

        restApi = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the Palworld REST API.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8212;
            description = "REST API TCP port. Not opened in the firewall by default.";
          };
        };

        portForward = {
          enable = lib.mkEnableOption "nftables DNAT port forwarding for Palworld";
          destAddr = lib.mkOption {
            type = lib.types.str;
            description = "LAN IPv4 address to forward Palworld ports to";
            example = "10.0.0.3";
          };
          destAddr6 = lib.mkOption {
            type = lib.types.str;
            default = "fd00:beef::3";
            description = "LAN IPv6 address used when allowing forwarded traffic";
          };
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          users.users.palworld = {
            home = cfg.dataDir;
            createHome = true;
            isSystemUser = true;
            group = "palworld";
          };
          users.groups.palworld = { };

          nixpkgs.config.allowUnfree = true;

          networking.firewall.allowedUDPPorts = [
            cfg.port
            cfg.queryPort
          ];

          systemd.services.palworld = {
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            description = "Palworld Dedicated Server";

            path = [
              pkgs.bash
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnused
              pkgs.steamcmd
              pkgs.steam-run
            ];

            preStart = ''
              ${pkgs.steamcmd}/bin/steamcmd \
                +force_install_dir ${serverDir} \
                +login anonymous \
                +app_update 2394010 validate \
                +quit

              # PalServer looks for the Steam client library under the user's
              # home directory, not in the SteamCMD install directory.
              mkdir -p ${cfg.dataDir}/.steam/sdk64
              steamclient=$(${pkgs.findutils}/bin/find \
                ${cfg.dataDir}/.steam ${cfg.dataDir}/.local \
                -name steamclient.so -type f 2>/dev/null | ${pkgs.coreutils}/bin/head -n 1 || true)
              if [ -n "$steamclient" ]; then
                ${pkgs.coreutils}/bin/ln -sf "$steamclient" ${cfg.dataDir}/.steam/sdk64/steamclient.so
              fi

              mkdir -p ${configDir}

              read_secret() {
                ${pkgs.gnused}/bin/sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' "$1" \
                  | ${pkgs.coreutils}/bin/tr -d '\n'
              }

              {
                ${pkgs.coreutils}/bin/echo '[/Script/Pal.PalGameWorldSettings]'
                ${pkgs.coreutils}/bin/printf 'OptionSettings=('
                ${pkgs.coreutils}/bin/printf '%s' ${lib.escapeShellArg settingLine}
              ${lib.optionalString (cfg.serverPasswordFile != null) ''
                server_password=$(read_secret ${cfg.serverPasswordFile})
                ${pkgs.coreutils}/bin/printf ',ServerPassword="%s"' "$server_password"
              ''}
              ${lib.optionalString (cfg.adminPasswordFile != null) ''
                admin_password=$(read_secret ${cfg.adminPasswordFile})
                ${pkgs.coreutils}/bin/printf ',AdminPassword="%s"' "$admin_password"
              ''}
                ${pkgs.coreutils}/bin/printf ')\n'
              } > ${settingsFile}

              chmod 0600 ${settingsFile}
            '';

            script = ''
              export SteamAppId=2394010
              exec ${pkgs.steam-run}/bin/steam-run ${serverDir}/PalServer.sh ${lib.escapeShellArgs launchArgs}
            '';

            serviceConfig = {
              # serverDir is created by the SteamCMD pre-start hook; the data
              # directory itself is created by the users-groups activation.
              WorkingDirectory = cfg.dataDir;
              User = "palworld";
              Group = "palworld";
              Restart = "always";
              RestartSec = 10;
              TimeoutStopSec = "120s";
              LimitNOFILE = 65536;
            };
          };
        })

        (lib.mkIf cfg.portForward.enable {
          networking.nat.forwardPorts = [
            {
              sourcePort = cfg.port;
              proto = "udp";
              destination = "${cfg.portForward.destAddr}:${toString cfg.port}";
            }
            {
              sourcePort = cfg.queryPort;
              proto = "udp";
              destination = "${cfg.portForward.destAddr}:${toString cfg.queryPort}";
            }
          ];

          networking.firewall.extraInputRules = ''
            ip6 daddr ${cfg.portForward.destAddr6} udp dport { ${toString cfg.port}, ${toString cfg.queryPort} } accept
          '';
        })
      ];
      sops.secrets.palworld_admin_password = {
        owner = "palworld";
        mode = "0400";
      };
      services.palworld = {
        enable = true;
        dataDir = "/servers/palworld";
        adminPasswordFile = config.sops.secrets.palworld_admin_password.path;
      };
    };
}
