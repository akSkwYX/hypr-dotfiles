{
  description = "My Hypr environment configuration as a flake module";

  outputs = { self, ... }: {
    homeModules.default = import ./hypr-module.nix;
  };
}
