{ config, pkgs, lib, fetchurl, ... }:
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
    (self: super: {
      my_ndi = super.ndi.overrideAttrs
        (attrs: rec {
          src = fetchurl {
            name = "${attrs.pname}-${attrs.version}.tar.gz";
            url = "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz";
            hash = "sha256:0lsiw523sqr6ydwxnikyijayfi55q5mzvh1zi216swvj5kfbxl00";
          };
        });
    })
  ];

}
