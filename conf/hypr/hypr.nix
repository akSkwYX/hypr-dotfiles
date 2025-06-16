{ config, pkgs, lib, ... }:
{
  imports = [
    ./scripts/scripts.nix
  ];

  home.file = {
    ".config/hypr" = {
      source = ./confFiles;
      recursive = true;
    };
  };
}
