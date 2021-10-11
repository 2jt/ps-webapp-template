let
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/tags/20.09";
    rev = "cd63096d6d887d689543a0b97743d28995bc9bc3";
  }) { };

  easy-purescript = import (builtins.fetchGit {
    url = "https://github.com/justinwoo/easy-purescript-nix.git";
    rev = "d9a37c75ed361372e1545f6efbc08d819b3c28c8";
  }) { inherit pkgs; };

in pkgs // {
  dev = {
    inherit (pkgs) nodejs nixops yarn yarn2nix;
    inherit (pkgs.nodePackages) parcel-bundler;
    purescript = easy-purescript.purs-0_14_4;
    inherit (easy-purescript) spago spago2nix;
  };
}
