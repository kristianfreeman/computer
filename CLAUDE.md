# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Build darwin configuration: `darwin-rebuild build --flake .#<hostname>`
- Apply darwin configuration: `darwin-rebuild switch --flake .#<hostname>`
- Build NixOS configuration: `nixos-rebuild build --flake .#sauron`
- Apply NixOS configuration: `sudo nixos-rebuild switch --flake /etc/nixos`

## Code Style Guidelines
- Indentation: 2 spaces (as per .editorconfig)
- Line endings: LF (Unix-style)
- Always insert final newline
- Follow Nix formatting conventions for .nix files
- Use descriptive variable names in camelCase
- Group related configurations together logically
- Maintain host-specific configurations in separate files
- Keep common home configurations in common.nix
- Document non-obvious code with brief comments
- Sort package lists alphabetically
- Prefer explicit imports over implicit ones
- Use relative imports for local modules
- Follow the existing pattern for host configurations