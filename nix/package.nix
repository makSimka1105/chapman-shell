{ lib, stdenvNoCC, python3 }:
stdenvNoCC.mkDerivation {
  pname = "chapman-shell";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [ ../shell ../themes ../bin ../niri.kdl ../niri-theme.kdl ];
  };

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/share/chapman-shell $out/bin
    cp -r shell themes bin niri.kdl niri-theme.kdl $out/share/chapman-shell/
    patchShebangs $out/share/chapman-shell/bin
    ln -s $out/share/chapman-shell/bin/chapman-shell $out/share/chapman-shell/bin/chapman-usage $out/bin/
  '';

  meta.mainProgram = "chapman-shell";
}
