# Nix Configuration

This repository contains my personal Nix configurations for managing multiple machines running both macOS (via nix-darwin) and Linux (NixOS).

You can read more about the motivations behind this project [here](https://kristianfreeman.com/my-starter-macos-nix-config).

## Overview

These configurations are written by Kristian Freeman and are open-source on GitHub.

The project uses [Nix Flakes](https://nixos.wiki/wiki/Flakes) to manage reproducible system configurations across different machines. [Home Manager](https://github.com/nix-community/home-manager) is used to manage user-specific configurations and dotfiles.

## Features

- Cross-platform configurations with shared settings
- Role-based configuration (development, media, music)
- Integrated homebrew management on macOS
- Dotfiles for various tools:
  - Neovim
  - Ghostty and Kitty terminals
  - Zsh
  - bat
  - btop
  - And more

## Usage

To build and apply configurations:

```bash
# Build darwin configuration
darwin-rebuild build --flake .#<hostname>

# Apply darwin configuration
darwin-rebuild switch --flake .#<hostname>

# Build NixOS configuration
nixos-rebuild build --flake .#sauron

# Apply NixOS configuration
sudo nixos-rebuild switch --flake /etc/nixos
```

---

A previous version of this config used custom scripts with Homebrew. You can find that [here](https://github.com/kristianfreeman/computer/tree/archive).
