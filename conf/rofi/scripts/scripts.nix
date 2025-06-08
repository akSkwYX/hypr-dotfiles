{ config, pkgs, ... }:
{
  home.file = {
    ".config/rofi/scripts/launcher.sh" = {
      text = builtins.readFile ./launcher.sh;
      executable = true;
      target = ".config/rofi/scripts/launcher.sh";
    };
  };
}
