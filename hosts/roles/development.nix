# Development machine role configuration
{ config, pkgs, ... }:

{
  # Development tools via Homebrew
  homebrew.brews = [
    "arp-scan"
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
    "google-chrome"
    "imageoptim"
    "notion"
    "obsidian"
    "screen-studio"
    "signal"
    "slack"
    "telegram"
  ];

  # Development tools via Nix
  environment.systemPackages = [
    pkgs.act
    pkgs.bundix
    pkgs.caddy
    pkgs.cloc
    pkgs.cmake
    pkgs.php84Packages.composer
    pkgs.ffmpeg
    pkgs.fswatch
    pkgs.gh
    pkgs.helix
    pkgs.heroku
    pkgs.hledger
    pkgs.hledger-ui
    pkgs.hledger-web
    pkgs.hugo
    pkgs.intelephense
    pkgs.mpv
    pkgs.neofetch
    pkgs.nodePackages.npm-check-updates
    pkgs.pandoc
    pkgs.php84
    pkgs.pnpm
    pkgs.pipx
    pkgs.rclone
    pkgs.solana-cli
  ];

  # Composer configuration
  environment.variables = {
    COMPOSER_HOME = "$HOME/.composer";
    COMPOSER_CACHE_DIR = "$HOME/.cache/composer";
  };
}
