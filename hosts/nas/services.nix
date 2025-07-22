{ config, lib, pkgs, ... }:
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
  
  # Dashboard (keeping your existing Glance)
  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        host = "0.0.0.0";
        port = 80;
      };
    };
  };
  
  # Cloudflare Tunnel
  services.cloudflared = {
    enable = true;
    tunnels = {
      "nas-tunnel" = {
        credentialsFile = config.sops.secrets.cloudflare_tunnel_credentials.path;
        default = "http_status:404";
        
        ingress = {
          # Media services
          "jellyfin.freemans.house" = "http://localhost:8096";
          "music.freemans.house" = "http://localhost:4533";  # Navidrome
          
          # *arr services
          "sonarr.freemans.house" = "http://localhost:8989";
          "radarr.freemans.house" = "http://localhost:7878";
          "prowlarr.freemans.house" = "http://localhost:9696";
          "bazarr.freemans.house" = "http://localhost:6767";
          "transmission.freemans.house" = "http://localhost:9091";
          
          # Dashboard
          "nas.freemans.house" = "http://localhost:80";  # Glance
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
