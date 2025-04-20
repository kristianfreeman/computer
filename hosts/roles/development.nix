# Development machine role configuration
{ config, pkgs, ... }:

{
  # Development tools via Homebrew
  homebrew.brews = [
    "libyaml"
    "postgresql@14"
    "rbenv"
    "ruby-build"
    "uv"
  ];

  # Development casks
  homebrew.casks = [
    "balenaetcher"
    "boltai"
    "claude"
    "cleanshot"
    "cyberduck"
    "discord"
    "firefox"
    "google-chrome"
    "imageoptim"
    "notion"
    "obsidian"
    "screen-studio"
    "signal"
    "slack"
    "tailscale"
    "telegram"
    "visual-studio-code"
  ];

  # Developer-focused Mac App Store apps
  homebrew.masApps = {
    Adblock = 1402042596;
    Copilot = 1447330651;
  };

  # Development tools via Nix
  environment.systemPackages = [
    pkgs.aerospace
    pkgs.bundix
    pkgs.caddy
    pkgs.cloc
    pkgs.ffmpeg
    pkgs.gh
    pkgs.heroku
    pkgs.hugo
    pkgs.neofetch
    pkgs.pnpm
    pkgs.rclone
    pkgs.solana-cli
  ];
}
