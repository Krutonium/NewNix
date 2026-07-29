{ ... }:
{
  flake.homeModules.editors =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      dotnet = (
        with pkgs.dotnetCorePackages;
        combinePackages [
          dotnet_8.sdk
          dotnet_9.sdk
          dotnet_10.sdk
        ]
      );
    in
    {
      config = lib.mkIf osConfig.services.desktopManager.gnome.enable {
        home.sessionVariables = {
          DOTNET_ROOT = "${dotnet}/share/dotnet";
        };

        home.packages = with pkgs; [
          # LSPs / formatters
          nixd
          nixfmt

          dotnet
          #omnisharp-roslyn
          csharp-ls

          # Editors
          zed-editor

          jetbrains.rider
          #jetbrains.idea
        ];

        programs.zed-editor = {
          enable = true;

          userSettings = {
            #
            # General
            #
            vim_mode = false;

            #
            # Disable AI
            #
            features = {
              edit_prediction_provider = "none";
            };

            assistant = {
              enabled = false;
            };

            #
            # VSCode keybindings
            #
            base_keymap = "VSCode";

            #
            # Formatting
            #
            format_on_save = "on";

            formatter = {
              language_server = {
                name = "nixd";
              };
            };

            #
            # Languages
            #
            languages = {
              Nix = {
                formatter = {
                  external = {
                    command = "nixfmt";
                  };
                };

                language_servers = [
                  "nixd"
                ];

                format_on_save = "on";
              };

              CSharp = {
                language_servers = [
                  "omnisharp"
                ];

                format_on_save = "on";
              };
            };

            #
            # Optional quality-of-life
            #
            telemetry = {
              diagnostics = false;
              metrics = false;
            };

            auto_update = false;
          };
        };
      };
    };
}
