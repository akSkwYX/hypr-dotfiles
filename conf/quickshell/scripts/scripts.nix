{ config, lib, pkgs, ... }:
{
  home.file = {
    ".config/quickshell/run.sh" = {
      text = builtins.readFile ./run.sh;
      executable = true;
      target = ".config/quickshell/run.sh";
    };
  };
}
