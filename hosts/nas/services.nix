# NAS Services Configuration
# 
# This module configures all services for the NAS, including:
# - Media services (Jellyfin, Navidrome)
# - *arr stack for media management
# - Dual Glance dashboards:
#   - External: https://freemans.house (via Cloudflare tunnel)
#   - Internal: http://nas (via nginx on port 80)
# - Container services (see containers.nix)
#
# All services are accessible both internally and via Cloudflare tunnel
# with appropriate URL routing based on access method.

{ config, lib, pkgs, ... }:
let
  # Central port configuration for all services
  ports = {
    # Media services
    jellyfin = 8096;
    jellyseerr = 5055;
    navidrome = 4533;
    
    # *arr stack
    sonarr = 8989;
    radarr = 7878;
    prowlarr = 9696;
    bazarr = 6767;
    
    # Download
    qbittorrent = 8090;
    
    # Dashboards
    glance = 8080;          # External access via Cloudflare
    glanceInternal = 8081;  # Internal access via nginx
    
    # Git service
    gitea = 3000;
    giteaSsh = 2222;  # SSH on 2222 to avoid conflict with host SSH
  };
in
{
  # ZFS maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
  
  # Network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
  
  # SSH access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  
  # VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
  
  # Media Services
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
    port = ports.jellyseerr;
  };
  
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/valhalla/media/music";
    };
  };
  
  # *arr services
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
  
  # Git service - Gitea
  services.gitea = {
    enable = true;
    database = {
      type = "postgres";
      passwordFile = pkgs.writeText "gitea-db-password" "";  # Empty password for local postgres
    };
    settings = {
      server = {
        DOMAIN = "git.freemans.house";
        ROOT_URL = "https://git.freemans.house/";
        HTTP_PORT = ports.gitea;
        SSH_PORT = ports.giteaSsh;
        SSH_LISTEN_PORT = ports.giteaSsh;
        DISABLE_SSH = false;
        START_SSH_SERVER = true;
      };
      service = {
        DISABLE_REGISTRATION = false;  # You can set this to true after creating your account
      };
    };
  };
  
  # Download client - qBittorrent Enhanced
  systemd.services.qbittorrent = {
    description = "qBittorrent-Enhanced-nox service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "qbittorrent";
      Group = "qbittorrent";
      ExecStart = "${pkgs.qbittorrent-enhanced-nox}/bin/qbittorrent-nox --webui-port=${toString ports.qbittorrent} --profile=/var/lib/qbittorrent";
      Restart = "on-failure";
      
      # Security hardening
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/qbittorrent" "/valhalla/downloads" ];
    };
  };

  # Create user and group for qBittorrent
  users.users.qbittorrent = {
    isSystemUser = true;
    group = "qbittorrent";
    home = "/var/lib/qbittorrent";
    createHome = true;
  };
  users.groups.qbittorrent = {};
  
  # Create media group for shared access
  users.groups.media = {
    members = [ "jellyfin" "sonarr" "radarr" "bazarr" "qbittorrent" "navidrome" ];
  };
  
  
  # Dashboard configuration - External instance (via Cloudflare)
  services.glance = {
    enable = true;
    openFirewall = true;
    settings = let
      glanceConfig = import ./glance-config.nix {
        inherit lib pkgs ports;
        urlStyle = "external";
      };
    in glanceConfig // {
      server = {
        host = "0.0.0.0";
        port = ports.glance;
      };
    };
  };
  
  # Dashboard configuration - Internal instance (for local/Tailscale)
  services.nginx = {
    enable = true;
    virtualHosts.${config.networking.hostName} = {
      listen = [ { addr = "0.0.0.0"; port = 80; } ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString ports.glanceInternal}";
        proxyWebsockets = true;
      };
    };
  };
  
  systemd.services.glance-internal = let
    glanceConfigInternal = import ./glance-config.nix {
      inherit lib pkgs ports;
      urlStyle = "internal";
      hostIP = config.networking.hostName;
    };
  in {
    description = "Glance Dashboard (Internal)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "glance-internal";
      WorkingDirectory = "/var/lib/glance-internal";
      ExecStart = "${pkgs.glance}/bin/glance --config /var/lib/glance-internal/glance.yml";
      Restart = "on-failure";
      RestartSec = 10;
    };
    
    preStart = ''
      cat > /var/lib/glance-internal/glance.yml <<'EOF'
${lib.generators.toYAML {} (glanceConfigInternal // {
  server = {
    host = "127.0.0.1";
    port = ports.glanceInternal;
  };
})}
EOF
    '';
  };
  
  # Open firewall for HTTP, qBittorrent, and Gitea
  networking.firewall.allowedTCPPorts = [ 80 ports.qbittorrent ports.gitea ports.giteaSsh ];
  
  # Cloudflare Tunnel
  services.cloudflared = {
    enable = true;
    tunnels = {
      "nas-tunnel" = {
        credentialsFile = config.sops.secrets.cloudflare_tunnel_credentials.path;
        default = "http_status:404";
        
        ingress = {
          # Media services
          "jellyfin.freemans.house" = "http://localhost:${toString ports.jellyfin}";
          "requests.freemans.house" = "http://localhost:${toString ports.jellyseerr}";
          "music.freemans.house" = "http://localhost:${toString ports.navidrome}";  # Navidrome
          
          # Dashboard
          "freemans.house" = "http://localhost:${toString ports.glance}";
          "nas.freemans.house" = "http://localhost:${toString ports.glance}";
          
          # Music tools
          "koito.freemans.house" = "http://localhost:4110";
          
          # Git service
          "git.freemans.house" = "http://localhost:${toString ports.gitea}";
        };
      };
    };
  };
  
  # Ensure media directories exist with proper permissions
  systemd.tmpfiles.rules = [
    "d /valhalla 0755 root root"
    "d /valhalla/media 0775 root media"
    "d /valhalla/downloads 0775 root media"
    "Z /valhalla/media - root media"
    "Z /valhalla/downloads - root media"
  ];
}
