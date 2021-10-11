{ pkgs ? import ./pkgs.nix }:

let
  projectSourceRoot = ../.;
  projectName = "my-app";
  mainJs = "index.js";
  filteredSrc =
    builtins.filterSource (path: _: baseNameOf path != "nix") projectSourceRoot;
  nodeModules = pkgs.mkYarnPackage {
    name = "node-modules";
    src = filteredSrc;
    installPhase = "ls; mkdir $out; cp -r node_modules $out/node_modules";
    distPhase = "true";
  };
  spagoDev = import ./spago-packages.nix { inherit pkgs; };

in pkgs.stdenv.mkDerivation {
  name = projectName;
  buildInputs = [ pkgs.dev.purescript ];
  src = filteredSrc;
  buildPhase = ''
    export HOME=./.
    ${spagoDev.installSpagoStyle}/bin/install-spago-style
    ${spagoDev.buildSpagoStyle}/bin/build-spago-style "./src/**/*.purs"
    ${pkgs.dev.spago}/bin/spago bundle-app --no-install --no-build -m Main -t tmp.js
    ${pkgs.dev.parcel-bundler}/bin/parcel build tmp.js -t node -d ./. -o ${mainJs}
  '';
  installPhase = ''
    mkdir $out
    cp -r ${nodeModules}/node_modules $out/
    cp ${mainJs} $out
    echo "#!/bin/bash" >> $out/${projectName}
    echo "${pkgs.dev.nodejs}/bin/node $out/${mainJs}" >> $out/${projectName}
    chmod +x $out/${projectName}
  '';
}
