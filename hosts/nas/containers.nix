# Container Services Configuration
# 
# This module manages containerized services using podman/docker
# Currently includes:
# - Koito: MusicBrainz scrobbler
# - PostgreSQL: Database for Koito

{ config, lib, pkgs, ... }:
{
  # Define sops secret for database password
  sops.secrets.koito_db_password = {
    restartUnits = [ "podman-koito-db.service" "podman-koito.service" ];
  };
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
        # PostgreSQL database for Koito
        koito-db = {
          image = "postgres:16";
          autoStart = true;
          environment = {
            POSTGRES_DB = "koitodb";
            POSTGRES_USER = "postgres";
          };
          environmentFiles = [
            "/run/secrets/koito-db-env"
          ];
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
          };
          environmentFiles = [
            "/run/secrets/koito-env"
          ];
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
    before = [ "podman-koito-db.service" "podman-koito.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman network create koito-net || true'";
    };
  };
  
  # Create environment files for containers
  systemd.services.koito-env-setup = {
    description = "Create environment files for Koito containers";
    after = [ "network.target" ];
    before = [ "podman-koito-db.service" "podman-koito.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Ensure secrets directory exists
      mkdir -p /run/secrets
      
      # Create environment file for PostgreSQL
      cat > /run/secrets/koito-db-env <<EOF
      POSTGRES_PASSWORD=$(cat ${config.sops.secrets.koito_db_password.path})
      EOF
      chmod 600 /run/secrets/koito-db-env
      
      # Create environment file for Koito with database URL
      DB_PASS=$(cat ${config.sops.secrets.koito_db_password.path})
      cat > /run/secrets/koito-env <<EOF
      KOITO_DATABASE_URL=postgres://postgres:$DB_PASS@db:5432/koitodb
      EOF
      chmod 600 /run/secrets/koito-env
    '';
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