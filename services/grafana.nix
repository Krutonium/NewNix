# monitoring.nix
#
# Sets up a full monitoring stack:
#   - Prometheus          (metrics collection & storage)
#   - node_exporter       (CPU, memory, network bandwidth per interface)
#   - prometheus-anubis-  (scrapes /run/anubis/anubis-forgejo/anubis-metrics.sock
#     exporter shim)       via a small systemd socket-proxy unit)
#   - Grafana             (dashboards)
#
# Import this file from your configuration.nix:
#
#   imports = [ ./monitoring.nix ];
#
# Then rebuild: nixos-rebuild switch
#
# Grafana will be available at http://localhost:3000  (admin / admin on first boot)
# Change the password immediately or set services.grafana.settings.security.admin_password.

{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.grafana == true) {
    # ──────────────────────────────────────────────────────────────────────────
    # 1.  NODE EXPORTER  (CPU, memory, network interfaces, disk, …)
    # ──────────────────────────────────────────────────────────────────────────
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;

      # Enable the collectors we care about.  The defaults already include
      # cpu, meminfo, netdev (per-interface bandwidth), filesystem, loadavg, etc.
      # Add anything extra here if needed.
      enabledCollectors = [
        "cpu"
        "meminfo"
        "netdev" # per-interface TX/RX bytes → bandwidth
        "diskstats"
        "loadavg"
        "filesystem"
        "systemd"
        "time"
        "uname"
        "netstat"
        "interrupts"
        "vmstat"
      ];
    };

    # ──────────────────────────────────────────────────────────────────────────
    # 2.  ANUBIS METRICS  via Unix-socket proxy
    #
    #     Anubis exposes a Prometheus-compatible text endpoint on a Unix socket:
    #       /run/anubis/anubis-forgejo/anubis-metrics.sock
    #
    #     Prometheus can only scrape HTTP endpoints, so we run a tiny socat
    #     proxy that wraps the socket in HTTP on 127.0.0.1:9101.
    #
    #     Anubis speaks raw HTTP over the socket, so socat just needs to bridge
    #     TCP ↔ Unix stream.
    # ──────────────────────────────────────────────────────────────────────────
    systemd.services.anubis-metrics-proxy = {
      description = "TCP→Unix proxy for Anubis Prometheus metrics socket";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        # Run as the user that owns the socket, or root if necessary.
        # Change 'anubis' to whatever user owns the socket on your system.
        User = "anubis";
        ExecStart = lib.escapeShellArgs [
          "${pkgs.socat}/bin/socat"
          "TCP-LISTEN:9101,reuseaddr,fork"
          "UNIX-CONNECT:/run/anubis/anubis-forgejo/anubis-metrics.sock"
        ];
      };
    };

    # ──────────────────────────────────────────────────────────────────────────
    # 3.  PROMETHEUS  (scrapes node_exporter + anubis proxy)
    # ──────────────────────────────────────────────────────────────────────────
    services.prometheus = {
      enable = true;
      port = 9090;
      retentionTime = "30d";

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
          scrape_interval = "15s";
        }
        {
          job_name = "anubis-forgejo";
          static_configs = [ { targets = [ "127.0.0.1:9101" ]; } ];
          scrape_interval = "15s";
          # Anubis serves metrics at /metrics by default.
          # Adjust metrics_path if your build uses a different path.
          metrics_path = "/metrics";
        }
      ];
    };

    # ──────────────────────────────────────────────────────────────────────────
    # 4.  GRAFANA
    # ──────────────────────────────────────────────────────────────────────────
    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = "10.0.0.1";
          http_port = 3000;
          # Set to your public domain if you reverse-proxy Grafana:
          # domain    = "grafana.example.com";
          # root_url  = "https://grafana.example.com/";
        };

        security = {
          admin_user = "krutonium";
          # WARNING: change this or use a secret file in production!
          admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
          secret_key = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
        };

        # Anonymous read-only access (optional – remove if not wanted)
        # auth.anonymous = {
        #   enabled  = true;
        #   org_role = "Viewer";
        # };
      };

      # ── Provision the Prometheus datasource automatically ──────────────────
      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:9090";
            isDefault = true;
            access = "proxy";
          }
        ];

        # ── Pre-built dashboards ──────────────────────────────────────────────
        #
        # We provision two dashboards as JSON files written into the Nix store.
        #
        dashboards.settings.providers = [
          {
            name = "default";
            orgId = 1;
            folder = "";
            type = "file";
            disableDeletion = false;
            options.path = "/etc/grafana/dashboards";
          }
        ];
      };
    };

    # Write the dashboard JSON files into /etc so Grafana can pick them up.
    environment.etc = {

      # ── System Overview dashboard ─────────────────────────────────────────
      "grafana/dashboards/system-overview.json".text = builtins.toJSON {
        title = "System Overview";
        uid = "system-overview";
        tags = [ "system" ];
        refresh = "30s";
        time = {
          from = "now-1h";
          to = "now";
        };
        panels = [

          # ── CPU Usage ──────────────────────────────────────────────────────
          {
            id = 1;
            title = "CPU Usage (%)";
            type = "timeseries";
            gridPos = {
              x = 0;
              y = 0;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = ''100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)'';
                legendFormat = "CPU %";
                refId = "A";
              }
            ];
            fieldConfig.defaults = {
              unit = "percent";
              min = 0;
              max = 100;
              custom.lineWidth = 2;
            };
          }

          # ── Memory Usage ───────────────────────────────────────────────────
          {
            id = 2;
            title = "Memory Usage";
            type = "timeseries";
            gridPos = {
              x = 12;
              y = 0;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = "node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes";
                legendFormat = "Used";
                refId = "A";
              }
              {
                expr = "node_memory_MemTotal_bytes";
                legendFormat = "Total";
                refId = "B";
              }
              {
                expr = "node_memory_MemAvailable_bytes";
                legendFormat = "Available";
                refId = "C";
              }
            ];
            fieldConfig.defaults = {
              unit = "bytes";
              custom.lineWidth = 2;
            };
          }

          # ── Network Bandwidth – all interfaces ─────────────────────────────
          {
            id = 3;
            title = "Network Bandwidth – Receive (all interfaces)";
            type = "timeseries";
            gridPos = {
              x = 0;
              y = 8;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = ''rate(node_network_receive_bytes_total{device!~"lo"}[2m])'';
                legendFormat = "{{device}} RX";
                refId = "A";
              }
            ];
            fieldConfig.defaults = {
              unit = "binBps";
              custom.lineWidth = 2;
            };
          }

          {
            id = 4;
            title = "Network Bandwidth – Transmit (all interfaces)";
            type = "timeseries";
            gridPos = {
              x = 12;
              y = 8;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = ''rate(node_network_transmit_bytes_total{device!~"lo"}[2m])'';
                legendFormat = "{{device}} TX";
                refId = "A";
              }
            ];
            fieldConfig.defaults = {
              unit = "binBps";
              custom.lineWidth = 2;
            };
          }

          # ── Network Errors / Drops ─────────────────────────────────────────
          {
            id = 5;
            title = "Network Errors & Drops (all interfaces)";
            type = "timeseries";
            gridPos = {
              x = 0;
              y = 16;
              w = 12;
              h = 6;
            };
            targets = [
              {
                expr = ''rate(node_network_receive_errs_total{device!~"lo"}[2m])'';
                legendFormat = "{{device}} RX errs";
                refId = "A";
              }
              {
                expr = ''rate(node_network_transmit_errs_total{device!~"lo"}[2m])'';
                legendFormat = "{{device}} TX errs";
                refId = "B";
              }
              {
                expr = ''rate(node_network_receive_drop_total{device!~"lo"}[2m])'';
                legendFormat = "{{device}} RX drops";
                refId = "C";
              }
            ];
            fieldConfig.defaults = {
              unit = "pps";
              custom.lineWidth = 1;
            };
          }

          # ── Load Average ───────────────────────────────────────────────────
          {
            id = 6;
            title = "Load Average";
            type = "timeseries";
            gridPos = {
              x = 12;
              y = 16;
              w = 12;
              h = 6;
            };
            targets = [
              {
                expr = "node_load1";
                legendFormat = "1m";
                refId = "A";
              }
              {
                expr = "node_load5";
                legendFormat = "5m";
                refId = "B";
              }
              {
                expr = "node_load15";
                legendFormat = "15m";
                refId = "C";
              }
            ];
            fieldConfig.defaults.custom.lineWidth = 2;
          }

        ];
      };

      # ── Anubis dashboard ──────────────────────────────────────────────────
      "grafana/dashboards/anubis-forgejo.json".text = builtins.toJSON {
        title = "Anubis – Forgejo";
        uid = "anubis-forgejo";
        tags = [
          "anubis"
          "forgejo"
        ];
        refresh = "30s";
        time = {
          from = "now-1h";
          to = "now";
        };
        panels = [

          # Challenge requests per second
          {
            id = 1;
            title = "Challenges Issued (req/s)";
            type = "timeseries";
            gridPos = {
              x = 0;
              y = 0;
              w = 12;
              h = 8;
            };
            targets = [
              {
                # Adjust metric name to match what your Anubis build exposes.
                # Common names: anubis_challenges_total, anubis_challenge_requests_total
                expr = "rate(anubis_challenges_total[2m])";
                legendFormat = "challenges/s";
                refId = "A";
              }
            ];
            fieldConfig.defaults = {
              unit = "reqps";
              custom.lineWidth = 2;
            };
          }

          # Passed / failed challenges
          {
            id = 2;
            title = "Challenge Results";
            type = "timeseries";
            gridPos = {
              x = 12;
              y = 0;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = "rate(anubis_challenge_pass_total[2m])";
                legendFormat = "passed/s";
                refId = "A";
              }
              {
                expr = "rate(anubis_challenge_fail_total[2m])";
                legendFormat = "failed/s";
                refId = "B";
              }
            ];
            fieldConfig.defaults = {
              unit = "reqps";
              custom.lineWidth = 2;
            };
          }

          # Active / waiting connections
          {
            id = 3;
            title = "Active Connections";
            type = "timeseries";
            gridPos = {
              x = 0;
              y = 8;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = "anubis_active_connections";
                legendFormat = "active";
                refId = "A";
              }
            ];
            fieldConfig.defaults.custom.lineWidth = 2;
          }

          # Upstream request latency (if exposed)
          {
            id = 4;
            title = "Upstream Request Duration (p50 / p95 / p99)";
            type = "timeseries";
            gridPos = {
              x = 12;
              y = 8;
              w = 12;
              h = 8;
            };
            targets = [
              {
                expr = "histogram_quantile(0.50, rate(anubis_upstream_request_duration_seconds_bucket[2m]))";
                legendFormat = "p50";
                refId = "A";
              }
              {
                expr = "histogram_quantile(0.95, rate(anubis_upstream_request_duration_seconds_bucket[2m]))";
                legendFormat = "p95";
                refId = "B";
              }
              {
                expr = "histogram_quantile(0.99, rate(anubis_upstream_request_duration_seconds_bucket[2m]))";
                legendFormat = "p99";
                refId = "C";
              }
            ];
            fieldConfig.defaults = {
              unit = "s";
              custom.lineWidth = 2;
            };
          }

          # Bot score distribution (if Anubis exposes a histogram)
          {
            id = 5;
            title = "Bot Score Distribution";
            type = "timeseries";
            gridPos = {
              x = 0;
              y = 16;
              w = 24;
              h = 8;
            };
            targets = [
              {
                expr = "rate(anubis_bot_score_bucket[2m])";
                legendFormat = "score ≤ {{le}}";
                refId = "A";
              }
            ];
            fieldConfig.defaults = {
              unit = "short";
              custom.lineWidth = 1;
            };
          }

        ];
      };

    }; # end environment.etc

    # ──────────────────────────────────────────────────────────────────────────
    # 5.  FIREWALL  – open Grafana only on localhost by default.
    #     If you want external access, either reverse-proxy nginx/caddy in front,
    #     or add 3000 to allowedTCPPorts.  Prometheus & exporters are
    #     localhost-only and should NOT be exposed publicly.
    # ──────────────────────────────────────────────────────────────────────────
    # networking.firewall.allowedTCPPorts = [ 3000 ];  # uncomment for LAN access
    networking.firewall.interfaces.br0.allowedTCPPorts = [ 3000 ];

    # ──────────────────────────────────────────────────────────────────────────
    # 6.  OPTIONAL: nginx reverse-proxy with HTTPS
    #     Uncomment and adjust if you want Grafana behind a proper TLS endpoint.
    # ──────────────────────────────────────────────────────────────────────────
    # services.nginx = {
    #   enable = true;
    #   recommendedProxySettings = true;
    #   recommendedTlsSettings   = true;
    #   virtualHosts."grafana.example.com" = {
    #     enableACME = true;
    #     forceSSL   = true;
    #     locations."/" = {
    #       proxyPass       = "http://127.0.0.1:3000";
    #       proxyWebsockets = true;
    #     };
    #   };
    # };
    # security.acme.acceptTerms = true;
    # security.acme.defaults.email = "you@example.com";

  };
}
