# Container Services Configuration
# 
# This module manages containerized services using podman/docker
# Currently includes:
# - Koito: MusicBrainz scrobbler  
# - PostgreSQL: Database for Koito (passwordless for simplicity)

{ config, lib, pkgs, ... }:
{
  # Enable container management
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers = {
      backend = "podman";
      containers = {
        # PostgreSQL database for Koito - passwordless
        koito-db = {
          image = "postgres:16";
          autoStart = true;
          environment = {
            POSTGRES_DB = "koitodb";
            POSTGRES_USER = "postgres";
            POSTGRES_HOST_AUTH_METHOD = "trust";  # Allow passwordless connections
          };
          volumes = [
            "/var/lib/koito/db-data:/var/lib/postgresql/data"
          ];
          extraOptions = [
            "--network=koito-net"
            "--network-alias=db"
          ];
        };
        
        # Koito MusicBrainz scrobbler
        koito = {
          image = "gabehf/koito:latest";
          autoStart = true;
          dependsOn = [ "koito-db" ];
          environment = {
            KOITO_ALLOWED_HOSTS = "koito.freemans.house,${config.networking.hostName}:4110,192.168.68.216:4110";
            KOITO_DATABASE_URL = "postgres://postgres@db:5432/koitodb?sslmode=disable";
          };
          ports = [ "4110:4110" ];
          volumes = [
            "/var/lib/koito/koito-data:/etc/koito"
          ];
          extraOptions = [
            "--network=koito-net"
          ];
        };
      };
    };
  };
  
  # Create network for containers
  systemd.services.create-koito-network = {
    description = "Create koito network for containers";
    after = [ "network.target" ];
    before = [ "podman.service" ];
    wantedBy = [ "podman.service" "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman network exists koito-net || ${pkgs.podman}/bin/podman network create koito-net'";
    };
  };
  
  # Add explicit ordering to container services
  systemd.services."podman-koito-db" = {
    after = [ "create-koito-network.service" ];
    requires = [ "create-koito-network.service" ];
  };
  
  systemd.services."podman-koito" = {
    after = [ "create-koito-network.service" "podman-koito-db.service" ];
    requires = [ "create-koito-network.service" ];
  };
  
  # Ensure directories exist with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/koito 0755 root root"
    "d /var/lib/koito/db-data 0755 999 999"  # PostgreSQL UID/GID
    "d /var/lib/koito/koito-data 0755 root root"
  ];
  
  # Open firewall for Koito
  networking.firewall.allowedTCPPorts = [ 4110 ];
}