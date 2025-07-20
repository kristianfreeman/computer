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
    "docker"
    "discord"
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
    pkgs.act
    pkgs.bundix
    pkgs.caddy
    pkgs.cloc
    pkgs.cmake
    pkgs.ffmpeg
    pkgs.fswatch
    pkgs.gh
    pkgs.helix
    pkgs.heroku
    pkgs.hledger
    pkgs.hledger-ui
    pkgs.hledger-web
    pkgs.hugo
    pkgs.neofetch
    pkgs.nodePackages.npm-check-updates
    pkgs.pandoc
    pkgs.pnpm
    pkgs.pipx
    pkgs.rclone
    pkgs.solana-cli
  ];
}
