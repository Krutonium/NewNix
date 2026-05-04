{ ... }:
{
  flake.nixosModules.postgresql =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    with lib;
    with builtins;
    let
      sql_current = pkgs.postgresql_16;
      sql_upgrade = pkgs.postgresql_18_jit;
    in
    {
      key = "krutonium/nixosModules/postgresql"; #allow merges from multiple imports
      services = {
        postgresql = {
          enable = true;
          package = sql_current;
          enableJIT = true;
          initialScript = pkgs.writeText "init.sql" ''
            CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
            CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"

            CREATE ROLE "nextcloud" WITH LOGIN PASSWORD 'nextcloud';
            CREATE DATABASE "nextcloud" WITH OWNER "nextcloud"

            TEMPLATE template0
            LC_COLLATE = "C"
            LC_CTYPE = "C";
          '';

          settings = {
            max_connections = 16;
            shared_buffers = "8GB";
            work_mem = "256MB";
            maintenance_work_mem = "512MB";
            log_min_duration_statement = 10000;
          };
        };
      };
      containers.temp-pg.config.services.postgresql = {
        enable = true;
        package = sql_upgrade;
      };
      containers.temp-pg.config.system.stateVersion = "25.11";
      environment.systemPackages =
        let
          newpg = config.containers.temp-pg.config.services.postgresql;
        in
        [
          (pkgs.writeScriptBin "upgrade-pg-cluster" ''
            set -x
            export OLDDATA="${config.services.postgresql.dataDir}"
            export NEWDATA="${newpg.dataDir}"
            export OLDBIN="${config.services.postgresql.package}/bin"
            export NEWBIN="${newpg.package}/bin"

            install -d -m 0700 -o postgres -g postgres "$NEWDATA"
            cd "$NEWDATA"
            sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

            systemctl stop matrix-synapse
            systemctl stop nextcloud

            systemctl stop postgresql

            sudo -u postgres $NEWBIN/pg_upgrade \
              --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
              --old-bindir $OLDBIN --new-bindir $NEWBIN \
              "$@"
          '')
        ];
    };
}
