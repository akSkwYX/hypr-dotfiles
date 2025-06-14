{ config, lib, pkgs, ... }:
{
  home.file = {
    ".config/quickshell/run.sh" = {
      text = builtins.readFile ./run.sh;
      executable = true;
      target = ".config/quickshell/run.sh";
    };

    ".config/quickshell/clipboard-delete.sh" = {
      text = builtins.readFile ./clipboard-delete.sh;
      executable = true;
    };

    ".config/quickshell/clipboard.sh" = {
      text = builtins.readFile ./clipboard.sh;
      executable = true;
    };

    ".config/quickshell/emoji-picker.sh" = {
      text = builtins.readFile ./emoji-picker.sh;
      executable = true;
    };

    ".config/quickshell/main.sh" = {
      text = builtins.readFile ./main.sh;
      executable = true;
    };

    ".config/quickshell/pip.sh" = {
      text = builtins.readFile ./pip.sh;
      executable = true;
    };

    ".config/quickshell/record.sh" = {
      text = builtins.readFile ./record.sh;
      executable = true;
    };

    ".config/quickshell/screenshot.sh" = {
      text = builtins.readFile ./screenshot.sh;
      executable = true;
    };

    ".config/quickshell/util.sh" = {
      text = builtins.readFile ./util.sh;
      executable = true;
    };

    ".config/quickshell/wallpaper.sh" = {
      text = builtins.readFile ./wallpaper.sh;
      executable = true;
    };

    ".config/quickshell/workspace-action.sh" = {
      text = builtins.readFile ./workspace-action.sh;
      executable = true;
    };

    ".config/quickshell/toggles/specialws.sh" = {
      text = builtins.readFile ./toggles/specialws.sh;
      executable = true;
    };

    ".config/quickshell/toggles/util.sh" = {
      text = builtins.readFile ./toggles/util.sh;
      executable = true;
    };

    ".config/quickshell/scheme/gen-print-scheme.sh" = {
      text = builtins.readFile ./scheme/gen-print-scheme.sh;
      executable = true;
    };

    ".config/quickshell/scheme/gen-scheme.sh" = {
      text = builtins.readFile ./scheme/gen-scheme.sh;
      executable = true;
    };

    ".config/quickshell/scheme/main.sh" = {
      text = builtins.readFile ./scheme/main.sh;
      executable = true;
    };

    ".config/quickshell/scheme/autoadjust.py" = {
      source = ./scheme/autoadjust.py;
    };

    ".config/quickshell/scheme/score.py" = {
      source = ./scheme/score.py;
    };
  };
}
