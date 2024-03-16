{
  description = "A beancount example";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
        };

        src = pkgs.lib.cleanSource ./.;
      in
      rec
      {
        checks = {
          bean-check = pkgs.runCommandLocal "bean-check" { } ''
            mkdir -p $out
            ${pkgs.beancount}/bin/bean-check ${src}/main.beancount | tee $out/log
          '';
        };

        apps.fava = flake-utils.lib.mkApp { drv = pkgs.fava; };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.beancount-language-server

            pkgs.beancount
            pkgs.fava
          ];
        };
      });
}
