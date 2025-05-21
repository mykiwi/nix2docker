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
        
        packages.php-application = pkgs.stdenvNoCC.mkDerivation {
          name = "php-app";
          src = ./srv;
          installPhase = ''
            mkdir -p $out/srv
            cp -r . $out/srv
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
            self.packages.${system}.php-application
            pkgs.frankenphp
          ];
        };
        
      }
    );
}
