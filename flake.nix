{
  description = "Felix Booleans";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    utils.url   = "github:numtide/flake-utils";
    felix.url   = "github:bsaul/felix";
 };

  outputs = { self, nixpkgs, utils , felix }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        agda-stdlib = pkgs.agdaPackages.standard-library;
        felix-lib = felix.packages.${system}.default;

        agdaPkgs = [
          agda-stdlib
          felix-lib
        ];

        agda = pkgs.agda.withPackages (p: agdaPkgs);

      in {
        checks.whitespace = pkgs.stdenvNoCC.mkDerivation {
          name = "check-whitespace";
          dontBuild = true;
          src = ./.;
          doCheck = true;
          checkPhase = ''
            ${pkgs.haskellPackages.fix-whitespace}/bin/fix-whitespace --check
          '';
          installPhase = ''mkdir "$out"'';
        };

        packages.default = pkgs.agdaPackages.mkDerivation {
          pname = "felix";
          version = "0.0.1";
          src = ./.;

          buildInputs = [ agda ];

          everythingFile = "./src/Felix/Boolean.lagda.tex";

          meta = with pkgs.lib; {
            description = "Felix Booleans";
            homepage = "https://github.com/conal/felix-boolean";
            # no license file, all rights reserved?
            # license = licenses.mit;
            # platforms = platforms.unix;
            # maintainers = with maintainers; [ ];
          };
        };


        devShells.default = pkgs.mkShell {
          buildInputs = [
            agda
            pkgs.graphviz
            pkgs.haskellPackages.fix-whitespace
          ];
        };
      }
    );
}