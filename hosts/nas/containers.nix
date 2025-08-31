# Container Services Configuration
# 
# This module manages containerized services using podman/docker
# Currently includes:
# - Koito: MusicBrainz scrobbler  
# - PostgreSQL: Database for Koito (passwordless for simplicity)
# - Ghost v6: Modern blogging platform with MySQL database

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
        
        # Ghost MySQL database
        ghost-db = {
          image = "mysql:8";
          autoStart = true;
          environment = {
            MYSQL_ROOT_PASSWORD = "ghostroot123";
            MYSQL_DATABASE = "ghostdb";
            MYSQL_USER = "ghostuser";
            MYSQL_PASSWORD = "ghostpass123";
          };
          volumes = [
            "/var/lib/ghost/mysql-data:/var/lib/mysql"
          ];
          extraOptions = [
            "--network=ghost-net"
            "--network-alias=ghost-mysql"
          ];
        };
        
        # Ghost v6 blogging platform
        ghost = {
          image = "ghost:5-alpine";  # Using v5 until v6 is stable in Docker Hub
          autoStart = true;
          dependsOn = [ "ghost-db" ];
          environment = {
            # Core configuration
            url = "https://blog.freemans.house";
            NODE_ENV = "production";
            
            # Database configuration
            database__client = "mysql";
            database__connection__host = "ghost-mysql";
            database__connection__user = "ghostuser";
            database__connection__password = "ghostpass123";
            database__connection__database = "ghostdb";
            
            # Mail configuration (update with your SMTP details)
            mail__transport = "SMTP";
            mail__options__host = "smtp.gmail.com";
            mail__options__port = "587";
            mail__options__secure = "false";
            mail__options__auth__user = "your-email@gmail.com";
            mail__options__auth__pass = "your-app-password";
            
            # Privacy and security
            privacy__useUpdateCheck = "false";
            privacy__useGoogleFonts = "false";
            privacy__useRpcPing = "false";
            privacy__useTinybirdAnalytics = "false";
          };
          ports = [ "2368:2368" ];
          volumes = [
            "/var/lib/ghost/content:/var/lib/ghost/content"
          ];
          extraOptions = [
            "--network=ghost-net"
          ];
        };
      };
    };
  };
  
  # Create networks for containers
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
  
  systemd.services.create-ghost-network = {
    description = "Create ghost network for containers";
    after = [ "network.target" ];
    before = [ "podman.service" ];
    wantedBy = [ "podman.service" "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman network exists ghost-net || ${pkgs.podman}/bin/podman network create ghost-net'";
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
  
  # Add explicit ordering to Ghost container services  
  systemd.services."podman-ghost-db" = {
    after = [ "create-ghost-network.service" ];
    requires = [ "create-ghost-network.service" ];
  };
  
  systemd.services."podman-ghost" = {
    after = [ "create-ghost-network.service" "podman-ghost-db.service" ];
    requires = [ "create-ghost-network.service" ];
  };
  
  # Ensure directories exist with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/koito 0755 root root"
    "d /var/lib/koito/db-data 0755 999 999"  # PostgreSQL UID/GID
    "d /var/lib/koito/koito-data 0755 root root"
    "d /var/lib/ghost 0755 root root"
    "d /var/lib/ghost/mysql-data 0755 999 999"  # MySQL UID/GID
    "d /var/lib/ghost/content 0755 1000 1000"  # Ghost UID/GID
  ];
  
  # Open firewall for Koito and Ghost
  networking.firewall.allowedTCPPorts = [ 4110 2368 ];
}