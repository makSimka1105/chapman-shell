{ lib, stdenvNoCC, python3, glib, gobject-introspection, makeWrapper }:
let
  pickPython = python3.withPackages (ps: [ ps.pygobject3 ]);
in
stdenvNoCC.mkDerivation {
  pname = "chapman-shell";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [ ../shell ../themes ../bin ../niri.kdl ];
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/share/chapman-shell $out/bin
    cp -r shell themes bin niri.kdl $out/share/chapman-shell/
    patchShebangs $out/share/chapman-shell/bin
    ln -s $out/share/chapman-shell/bin/chapman-shell $out/share/chapman-shell/bin/chapman-usage $out/bin/
    makeWrapper ${pickPython}/bin/python3 $out/bin/chapman-pick \
      --add-flags $out/share/chapman-shell/bin/chapman-pick \
      --prefix GI_TYPELIB_PATH : ${glib.out}/lib/girepository-1.0:${gobject-introspection}/lib/girepository-1.0
  '';

  meta.mainProgram = "chapman-shell";
}
