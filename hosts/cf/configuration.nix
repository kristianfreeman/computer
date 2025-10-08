{ config, pkgs, ... }:

let 
in
{
  imports = [
    ../darwin-common.nix
    ../darwin-homebrew.nix
    ../roles/development.nix
  ];

  homebrew.brews = [
    "cloudflared"
    "vips"
  ];

  homebrew.casks = [
    "spotify"
  ];
}
