{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.frankenphp
  ];

  enterShell = ''
    frankenphp version
  '';
}
