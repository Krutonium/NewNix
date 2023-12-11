{ pkgs, lib, ... }:

let
  mkFont =
    { name
    , url
    , hash
    , sourceRoot ? "."
    }: pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      pname = name;
      nativeBuildInputs = [ pkgs.unzip ];
      src = pkgs.fetchurl {
        inherit url hash;
        name = "${name}.zip";
      };
      setSourceRoot = "sourceRoot=`pwd`";
      installPhase = ''
        find ${sourceRoot} -type f -name '*.ttf' | while read f; do
          d="$out/share/fonts/truetype/${name}/$(basename "$f")"
          echo "installing $f to $d"
          install -Dm644 -D "$f" "$d"
        done
        find ${sourceRoot} -type f -name '*.otf' | while read f; do
          d="$out/share/fonts/opentype/${name}/$(basename "$f")"
          echo "installing $f to $d"
          install -Dm644 -D "$f" "$d"
        done
      '';
    };
  nerdify = { font, file ? "", mono ? false }:
    pkgs.stdenvNoCC.mkDerivation
      (rec {
        pname = "${font.pname}-nerd";
        name = pname;
        src = pkgs.fetchzip {
          url = https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FontPatcher.zip;
          sha256 = "sha256-H2dPUs6HVKJcjxy5xtz9nL3SSPXKQF3w30/0l7A0PeY=";
          stripRoot = false;
        };
        buildInputs = with pkgs; [
          argparse
          fontforge
          (python3.withPackages (ps: with ps; [ setuptools fontforge ]))
        ];
        buildPhase = ''
          find ${font}/${file} -type f -name '*.ttf' -or -name '*.otf' | while read f; do
            echo "nerdifying $f"
            python3 "$src/font-patcher" --complete ${if mono then "--mono" else ""} "$f"
          done
        '';
        installPhase = ''
          for f in *.ttf; do
            d="$out/share/fonts/truetype/${pname}/$f"
            echo "installing $f to $d"
            install -Dm644 -D "$f" "$d"
          done
          for f in *.otf; do
            d="$out/share/fonts/opentype/${pname}/$f"
            echo "installing $f to $d"
            install -Dm644 -D "$f" "$d"
          done
        '';
      }
      // lib.optionalAttrs (font ? version) {
        name = "${font.pname}-nerd-${font.version}";
        inherit (font) version;
      });
  new-heterodox-mono = mkFont {
    name = "new-heterodox-mono";
    url = "https://github.com/hckiang/font-new-heterodox-mono/archive/refs/heads/master.zip";
    hash = "sha256-FsJ0uJGKZ9nRS5gXokh0vwLs2aUQKB1R9Xu03T3giUA=";
  };
in
{
  fonts.fontconfig.enable = lib.mkForce true;
  home.packages = with pkgs; [
    (nerdify { font = new-heterodox-mono; file = "share/fonts/opentype/new-heterodox-mono/NewHeterodoxMono-Book.otf"; })
  ];
}
