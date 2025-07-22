# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./services.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Zpool config
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "valhalla" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # User config 
  users.users.kristian = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      git
      neovim
      tree
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Networking
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.hostName = "nas";
  networking.hostId = "db5d236d";
  networking.networkmanager.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/nas.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      cloudflare_tunnel_credentials = {
        owner = "cloudflared";
        restartUnits = [ "cloudflared-tunnel-nas-tunnel.service" ];
      };
    };
  };

  ##########
  system.stateVersion = "25.05"; # Don't change me
}

