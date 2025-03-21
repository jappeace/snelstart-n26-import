# I used chatgpt to generate this template and then just
# modified to how I normally use these things.
{
  description = "Snelstart importer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      hpkgs = pkgs.haskellPackages.override {
        overrides = hnew: hold: {
          snelstart-import = hnew.callCabal2nix "snelstart-import" ./. { };
          base64 = hnew.callHackageDirect {
              pkg = "base64";
              ver = "1.0";
              sha256 = "sha256-YLQqQWZ5B7w0tNJGEmPNumONwX5vQPHelC12iVBGMFU=";
            } {};
        };
      };
    in
    {
      defaultPackage.x86_64-linux =  hpkgs.snelstart-import;
      inherit pkgs;
      devShell.x86_64-linux = hpkgs.shellFor {
        packages = ps : [ ps."snelstart-import" ];
        withHoogle = false;

        buildInputs = [
          hpkgs.haskell-language-server
          pkgs.ghcid
          pkgs.cabal-install
        ];
      };
    };
}
