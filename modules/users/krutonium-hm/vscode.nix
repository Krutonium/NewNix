{ self, ... }:
{
  flake.homeModules.vscode =
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
      config = lib.mkIf (osConfig.services.displayManager.gdm.enable == true) {

        home.sessionVariables = {
          DOTNET_ROOT = "${dotnet}/share/dotnet";
        };
        programs.vscode = {
          enable = true;
          package = pkgs.vscode;

          extensions = with pkgs.vscode-extensions; [
            # Nix
            jnoortheen.nix-ide
            mkhl.direnv

            # C#
            ms-dotnettools.csharp

            # Quality of life
            editorconfig.editorconfig

            # Visual Studio Keybindings
            (pkgs.vscode-utils.extensionFromVscodeMarketplace {
              publisher = "ms-vscode";
              name = "vs-keybindings";
              version = "0.2.1";
              sha256 = "sha256-NnLjx3fKldg6DSA4ssUt0Vevm1w8KnjEZTINZxqM7cA=";
            })
          ];

          userSettings = {
            # Nix IDE — use nixd as the language server
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "nix.serverSettings" = {
              nixd = {
                formatting = {
                  command = [ "nixfmt" ];
                };
                options = {
                  # Point nixd at your flake so it can resolve options
                  nixos = {
                    expr = "(builtins.getFlake \"${self}\").nixosConfigurations.uGamingPC.options";
                  };
                  home_manager = {
                    expr = "(builtins.getFlake \"${self}\").homeConfigurations.krutonium.options";
                  };
                };
              };
            };

            # C# / OmniSharp
            "dotnet.defaultSolution" = "disable";
            "omnisharp.enableRoslynAnalyzers" = true;
            "omnisharp.enableEditorConfigSupport" = true;
            "omnisharp.organizeImportsOnFormat" = true;

            # Editor
            "editor.formatOnSave" = true;
            "editor.rulers" = [ 120 ];
            "editor.bracketPairColorization.enabled" = true;
            "editor.guides.bracketPairs" = "active";
            "editor.inlayHints.enabled" = "on";
            "files.trimTrailingWhitespace" = true;
            "files.insertFinalNewline" = true;

            # Telemetry off
            "telemetry.telemetryLevel" = "off";
          };
        };
        home.packages = with pkgs; [
          nixd
          dotnet
          nixfmt

          rustc
          cargo
          rust-analyzer
          clippy
          rustfmt
        ];
      };
    };
}
