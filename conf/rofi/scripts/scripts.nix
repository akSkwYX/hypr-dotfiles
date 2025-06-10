{ config, pkgs, ... }:
{
  home.file = {
    ".config/rofi/scripts/appLauncher.sh" = {
      text = builtins.readFile ./appLauncher.sh;
      executable = true;
      target = ".config/rofi/scripts/appLauncher.sh";
    };

    ".config/rofi/scripts/powerLauncher.sh" = {
      text = builtins.readFile ./powerLauncher.sh;
      executable = true;
      target = ".config/rofi/scripts/powerLauncher.sh";
    };

    ".config/rofi/scripts/wallLauncher.sh" = {
      text = builtins.readFile ./wallLauncher.sh;
      executable = true;
      target = ".config/rofi/scripts/wallLauncher.sh";
    };
  };
}
