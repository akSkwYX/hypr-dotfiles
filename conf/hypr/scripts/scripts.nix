{ config, lib, pkgs, ... }:
{
  home.file = {
    ".config/hypr/scripts/weather.sh" = {
      text = builtins.readFile ./weather.sh;
      executable = true;
      target = ".config/hypr/scripts/weather.sh";
    };

    ".config/hypr/scripts/songdetail.sh" = {
      text = builtins.readFile ./songdetail.sh;
      executable = true;
      target = ".config/hypr/scripts/songdetail.sh";
    };
  };
}
