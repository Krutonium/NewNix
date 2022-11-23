{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      discord =
        final.symlinkJoin {
          name = "discord";
          paths = [ prev.discord ];
          nativeBuildInputs = [ final.makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/discord --add-flags "--use-gl=desktop"
            wrapProgram $out/bin/Discord --add-flags "--use-gl=desktop"
          '';

          passthru.unwrapped = prev.discord;

          meta = {
            inherit (prev.discord.meta) homepage description longDescription maintainers;
            mainProgram = "discord";
          };
        };
    })
    (final: prev: {
      element-desktop =
        final.symlinkJoin {
          name = "element-desktop";
          paths = [ prev.element-desktop ];
          nativeBuildInputs = [ final.makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/element-desktop --add-flags "--use-gl=desktop"
          '';
          passthru.unwrapped = prev.element-desktop;
          meta = {
            inherit (prev.element-desktop.meta) homepage description longDescription maintainers;
            mainProgram = "element-desktop";
          };
        };
    })
  ];
}
