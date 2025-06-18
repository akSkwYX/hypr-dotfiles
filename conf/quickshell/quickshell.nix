{ config, pkgs, lib, ... }:
{
  home.file = {
    ".config/quickshell/assets" = {
      source = ./confFiles/assets;
      recursive = true;
    };

    ".config/quickshell/config" = {
      source = ./confFiles/config;
      recursive = true;
    };

    ".config/quickshell/data" = {
      source = ./confFiles/data;
      recursive = true;
    };

    ".config/quickshell/modules" = {
      source = ./confFiles/modules;
      recursive = true;
    };

    ".config/quickshell/services" = {
      source = ./confFiles/utils;
      recursive = true;
    };

    ".config/quickshell/widgets" = {
      source = ./confFiles/widgets;
      recursive = true;
    };

    ".config/quickshell/shell.qml" = {
      source = ./confFiles/shell.qml;
    };

    ".config/quickshell/config" = {
      source = ./confFiles/config;
      recursive = true;
    };
  };
}
