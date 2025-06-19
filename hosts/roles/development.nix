# Development machine role configuration
{ config, pkgs, ... }:

{
  # Development tools via Homebrew
  homebrew.brews = [
    "git-filter-repo"
    "gh"
    "libyaml"
    "postgresql@14"
    "uv"
  ];

  homebrew.taps = [];

  # Development casks
  homebrew.casks = [
    "amazon-q"
    "balenaetcher"
    "boltai"
    "chatgpt"
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
  ];

  # Development tools via Nix
  environment.systemPackages = [
    pkgs.bundix
    pkgs.caddy
    pkgs.cloc
    pkgs.cmake
    pkgs.ffmpeg
    pkgs.fswatch
    pkgs.gh
    pkgs.heroku
    pkgs.hledger
    pkgs.hledger-ui
    pkgs.hledger-web
    pkgs.hugo
    pkgs.neofetch
    pkgs.nodePackages.npm-check-updates
    pkgs.pnpm
    pkgs.rclone
    pkgs.solana-cli
  ];
}
