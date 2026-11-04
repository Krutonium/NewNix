{ ... }:
{
  flake.homeModules.rutorrent =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      endpoint = "https://rutorrent.krutonium.ca";

      rutorrent-add = pkgs.writeShellApplication {
        name = "rutorrent-add";
        runtimeInputs = with pkgs; [
          coreutils
          curl
          libnotify
          libsecret
          xdg-utils
          zenity
        ];
        text = ''
          endpoint="${endpoint}"

          get_password() {
            if [[ -n "''${RUTORRENT_PASSWORD:-}" ]]; then
              printf '%s\n' "$RUTORRENT_PASSWORD"
              return 0
            fi

            local password
            if password="$(secret-tool lookup service rutorrent username krutonium 2>/dev/null)" \
              && [[ -n "$password" ]]; then
              printf '%s\n' "$password"
              return 0
            fi

            if ! password="$(zenity --password --title='ruTorrent' \
              --text='Password for ruTorrent (user krutonium):' 2>/dev/null)"; then
              return 1
            fi
            [[ -n "$password" ]] || return 1

            printf '%s' "$password" \
              | secret-tool store --label='ruTorrent (krutonium)' \
                  service rutorrent username krutonium 2>/dev/null \
              || true

            printf '%s\n' "$password"
          }

          display_name() {
            case "$1" in
              magnet:*) printf 'magnet link\n' ;;
              file://*) basename "''${1#file://}" ;;
              *) basename "$1" ;;
            esac
          }

          add_one() {
            local password="$1"
            local target="$2"
            local path response name
            local -a curl_args=(--silent --show-error --location --fail --user "krutonium:$password")

            case "$target" in
              magnet:*|http://*|https://*)
                curl_args+=(--data-urlencode "url=$target" --data "json=1")
                ;;
              file://*)
                path="''${target#file://}"
                path="$(printf '%b' "''${path//%/\\x}")"
                curl_args+=(--form "torrent_file=@$path" --form "json=1")
                ;;
              *)
                curl_args+=(--form "torrent_file=@$target" --form "json=1")
                ;;
            esac

            name="$(display_name "$target")"
            response="$(curl "''${curl_args[@]}" "$endpoint/php/addtorrent.php" || true)"

            if [[ "$response" == *'"Success"'* ]]; then
              notify-send "ruTorrent" "Added: $name"
            else
              notify-send -u critical "ruTorrent" "Failed to add: $name"
              printf '%s\n' "$response" >&2
              if [[ -z "$response" ]]; then
                secret-tool clear service rutorrent username krutonium 2>/dev/null || true
              fi
              return 1
            fi
          }

          if [[ $# -eq 0 ]]; then
            xdg-open "$endpoint/" >/dev/null 2>&1 &
            exit 0
          fi

          password="$(get_password)" || {
            notify-send -u critical "ruTorrent" "No password supplied"
            exit 1
          }

          status=0
          for target in "$@"; do
            add_one "$password" "$target" || status=1
          done
          exit "$status"
        '';
      };
    in
    {
      config = lib.mkIf osConfig.services.desktopManager.gnome.enable {
        home.packages = [ rutorrent-add ];

        xdg.desktopEntries.rutorrent = {
          name = "ruTorrent";
          genericName = "BitTorrent client";
          comment = "Add torrents and magnet links to the remote ruTorrent instance";
          exec = "${rutorrent-add}/bin/rutorrent-add %U";
          icon = "application-x-bittorrent";
          terminal = false;
          categories = [
            "Network"
            "FileTransfer"
          ];
          mimeType = [
            "application/x-bittorrent"
            "x-scheme-handler/magnet"
          ];
        };
      };
    };
}
