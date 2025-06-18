{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/quickshell"  = {
      source = ./confFiles;
      recursive = true;
    };
  };
}
