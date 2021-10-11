{ pkgs ? import ./pkgs.nix }:
pkgs.mkShell {
  buildInputs = builtins.attrValues pkgs.dev;
  shellHook = ''
    echo -n "Purescript: "
    purs --version
    echo "Spago: "
    spago --version
    echo "Nodejs: "
    node --version
    echo "Parcel: "
    parcel --version
    echo "Nixops: "
    nixops --version
  '';
}
