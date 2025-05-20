{ pkgs ? import <nixpkgs> {} }:

let
  php-app = pkgs.stdenvNoCC.mkDerivation {
    name = "php-app";
    src = ./srv;
    installPhase = ''
      cp -r . $out
    '';
  };
in 
pkgs.dockerTools.buildLayeredImage {
  name = "application";
  tag = "latest";
  config = {
    Cmd = ["${pkgs.frankenphp}/bin/frankenphp" "php-server" "--listen=0.0.0.0:80" "--root=/srv/public"];
    ExposedPorts = {
      "80/tcp" = {};
    };
  };
  contents = [
    php-app
    pkgs.frankenphp
  ];
}
