# NAS Services Configuration
# 
# This module configures all services for the NAS, including:
# - Media services (Jellyfin, Navidrome)
# - *arr stack for media management
# - Dual Glance dashboards:
#   - External: https://freemans.house (via Cloudflare tunnel)
#   - Internal: http://nas (via nginx on port 80)
#
# All services are accessible both internally and via Cloudflare tunnel
# with appropriate URL routing based on access method.

{ config, lib, pkgs, ... }:
let
  # Central port configuration for all services
  ports = {
    # Media services
    jellyfin = 8096;
    navidrome = 4533;
    
    # *arr stack
    sonarr = 8989;
    radarr = 7878;
    prowlarr = 9696;
    bazarr = 6767;
    
    # Download
    transmission = 9091;
    
    # Dashboards
    glance = 8080;          # External access via Cloudflare
    glanceInternal = 8081;  # Internal access via nginx
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
  
  # Download client
  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      rpc-whitelist-enabled = false;
      download-dir = "/valhalla/downloads";
      incomplete-dir = "/valhalla/downloads/.incomplete";
    };
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
  
  # Open firewall for HTTP
  networking.firewall.allowedTCPPorts = [ 80 ];
  
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
          "music.freemans.house" = "http://localhost:${toString ports.navidrome}";  # Navidrome
          
          # *arr services
          "sonarr.freemans.house" = "http://localhost:${toString ports.sonarr}";
          "radarr.freemans.house" = "http://localhost:${toString ports.radarr}";
          "prowlarr.freemans.house" = "http://localhost:${toString ports.prowlarr}";
          "bazarr.freemans.house" = "http://localhost:${toString ports.bazarr}";
          "transmission.freemans.house" = "http://localhost:${toString ports.transmission}";
          
          # Dashboard
          "freemans.house" = "http://localhost:${toString ports.glance}";
          "nas.freemans.house" = "http://localhost:${toString ports.glance}";
        };
      };
    };
  };
  
  # Ensure media directories exist
  systemd.tmpfiles.rules = [
    "d /valhalla/media 0755 jellyfin jellyfin"
    "d /valhalla/media/movies 0755 jellyfin jellyfin"
    "d /valhalla/media/tv 0755 jellyfin jellyfin"
    "d /valhalla/media/music 0755 navidrome navidrome"
    "d /valhalla/downloads 0755 transmission transmission"
  ];
}
