{
  description = "PHP Application";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        nativeBuildInputs = with pkgs; [];
        buildInputs = with pkgs; [];
      in {
        devShells.default = pkgs.mkShell {inherit nativeBuildInputs buildInputs;};

        packages.app-php-deps = pkgs.php.buildComposerProject (finalAttrs: {
          pname = "app";
          version = "1.0.0";
          src = ./srv;
          composerNoDev = false;
          composerStrictValidation = false;
          vendorHash = "sha256-gbRbnu1wk8NQxCSCT2YRzHC3Xiosg9qTybabffuwaa0=";
        });

        packages.app = pkgs.stdenvNoCC.mkDerivation {
          name = "app";
          src = ./srv;
          installPhase = ''
            mkdir -p $out/srv
            cp -r . $out/srv
            cp -r ${self.packages.${system}.app-php-deps}/share/php/app/vendor $out/srv/vendor
          '';
        };

        packages.docker-image = pkgs.dockerTools.buildLayeredImage {
          name = "php-app";
          tag = "latest";
          config = {
            Cmd = ["${pkgs.frankenphp}/bin/frankenphp" "php-server" "--listen=0.0.0.0:80" "--root=/srv/public"];
            ExposedPorts = {
              "80/tcp" = {};
            };
            WorkingDir = "/srv";
          };
          contents = [
            self.packages.${system}.app
            pkgs.frankenphp
          ];
        };
        
      }
    );
}
