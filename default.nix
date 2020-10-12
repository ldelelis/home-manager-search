{ }:
let
  hieNix = fetchTarball {
    url = "https://github.com/domenkozar/hie-nix/archive/36ffcc1d7e194fe4f6b85722f218fa89bd5098bf.tar.gz";
    sha256 = "03393r7ssycyzp47azg99v8rlc6nckqsrs55zafdy7w1g8bfh0h6";
  };
  hieOverlay = self: super: {hie-nix = import hieNix {};};
  pkgs = import <nixpkgs> { overlays = [ hieOverlay ];};
  hmModules = import <home-manager/modules> { configuration = {}; pkgs = pkgs; };
in
{
  modules = import ./nix/moduleparser.nix { pkgs = hmModules.options; };
}
