{
  description = "My Hypr environment configuration as a flake module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hyprland, quickshell, ... }: {
    hyprpkg = hyprland.packages."x86_64-linux".hyprland;
    quickshell.packages."x86_64-linux".default;
    homeModules.default = import ./hypr-module.nix;
  };
}
