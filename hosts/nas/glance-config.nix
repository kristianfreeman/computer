{ lib, pkgs, ports, urlStyle ? "internal", hostIP ? "nas" }:
let
  # Extract individual ports
  jellyfinPort = ports.jellyfin;
  jellyseerrPort = ports.jellyseerr;
  navidromePort = ports.navidrome;
  bonobPort = ports.bonob;
  sonarrPort = ports.sonarr;
  radarrPort = ports.radarr;
  prowlarrPort = ports.prowlarr;
  bazarrPort = ports.bazarr;
  qbittorrentPort = ports.qbittorrent;
  glancePort = ports.glance;
  giteaPort = ports.gitea;
  
  # URL generation based on access style
  urls = if urlStyle == "external" then {
    jellyfin = "https://jellyfin.freemans.house";
    jellyseerr = "https://requests.freemans.house";
    navidrome = "https://music.freemans.house";
    sonarr = "https://sonarr.freemans.house";
    radarr = "https://radarr.freemans.house";
    prowlarr = "https://prowlarr.freemans.house";
    bazarr = "https://bazarr.freemans.house";
    qbittorrent = "https://qbittorrent.freemans.house";
    glance = "https://nas.freemans.house";
    glanceAlt = "https://freemans.house";
    gitea = "https://git.freemans.house";
  } else {
    jellyfin = "http://${hostIP}:${toString jellyfinPort}/web/";
    jellyseerr = "http://${hostIP}:${toString jellyseerrPort}";
    navidrome = "http://${hostIP}:${toString navidromePort}";
    bonob = "http://${hostIP}:${toString bonobPort}";
    sonarr = "http://${hostIP}:${toString sonarrPort}";
    radarr = "http://${hostIP}:${toString radarrPort}";
    prowlarr = "http://${hostIP}:${toString prowlarrPort}";
    bazarr = "http://${hostIP}:${toString bazarrPort}";
    qbittorrent = "http://${hostIP}:${toString qbittorrentPort}";
    glance = "http://${hostIP}";
    glanceAlt = "http://${hostIP}";
    gitea = "http://${hostIP}:${toString giteaPort}";
  };
  
  # Build infrastructure monitor widget (only for internal)
  infrastructureWidget = {
    type = "monitor";
    title = "Infrastructure";
    cache = "1m";
    sites = [
      {
        title = "NAS";
        url = if urlStyle == "external" then urls.glance else urls.glanceAlt;
        icon = "mdi:nas";
      }
      {
        title = "Proxmox VE";
        url = "https://192.168.68.222:8006";
        icon = "mdi:server";
        allow-insecure = true;
      }
      {
        title = "Gitea";
        url = urls.gitea;
        icon = "si:gitea";
      }
    ];
  };
  
  # Build small column widgets based on access type
  smallColumnWidgets = [
    {
      type = "calendar";
      first-day-of-week = "monday";
    }
    {
      type = "weather";
      location = "San Marcos, Texas, United States";
      units = "imperial";
      hour-format = "12h";
    }
  ] ++ lib.optionals (urlStyle == "internal") [ infrastructureWidget ];
  
  glanceConfig = {
    theme = {
      background-color = "50 1 6";
      primary-color = "24 97 58";
      negative-color = "209 88 54";
    };
    
    pages = [
      {
        name = "Home";
        columns = [
          {
            size = "small";
            widgets = smallColumnWidgets;
          }
          {
            size = "full";
            widgets = [
              {
                type = "group";
                widgets = [
                  {
                    type = "hacker-news";
                    limit = 15;
                    collapse-after = 5;
                  }
                  {
                    type = "lobsters";
                    limit = 15;
                    collapse-after = 5;
                  }
                ];
              }
              {
                type = "clock";
                title = "World Time";
                hour-format = "12h";
                timezones = [
                  {
                    timezone = "America/Chicago";
                    label = "Central Time";
                  }
                  {
                    timezone = "Asia/Manila";
                    label = "Philippines";
                  }
                  {
                    timezone = "Europe/Amsterdam";
                    label = "Amsterdam";
                  }
                  {
                    timezone = "Europe/Berlin";
                    label = "Germany";
                  }
                  {
                    timezone = "Europe/London";
                    label = "London";
                  }
                ];
              }
              {
                type = "monitor";
                title = "Media Services";
                cache = "30s";
                sites = [
                  {
                    title = "Jellyfin";
                    url = urls.jellyfin;
                    icon = "si:jellyfin";
                  }
                  {
                    title = "Jellyseerr";
                    url = urls.jellyseerr;
                    icon = "mdi:jellyfish";
                  }
                  {
                    title = "Navidrome";
                    url = urls.navidrome;
                    icon = "mdi:music";
                  }
                ] ++ lib.optionals (urlStyle == "internal") [
                  {
                    title = "Bonob (Sonos)";
                    url = urls.bonob;
                    icon = "mdi:speaker";
                  }
                  {
                    title = "Sonarr";
                    url = urls.sonarr;
                    icon = "si:sonarr";
                  }
                  {
                    title = "Radarr";
                    url = urls.radarr;
                    icon = "si:radarr";
                  }
                  {
                    title = "Bazarr";
                    url = urls.bazarr;
                    icon = "mdi:message";
                  }
                  {
                    title = "Koito";
                    url = "http://${hostIP}:4110";
                    icon = "mdi:account-music";
                  }
                ];
              }
            ] ++ lib.optionals (urlStyle == "internal") [
              {
                type = "monitor";
                title = "Home Automation";
                cache = "30s";
                sites = [
                  {
                    title = "Homebridge";
                    url = "http://192.168.68.79:8581";
                    icon = "mdi:home-automation";
                  }
                  {
                    title = "Scrypted";
                    url = "https://192.168.68.69:10443";
                    icon = "mdi:cctv";
                    allow-insecure = true;
                  }
                ];
              }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "bookmarks";
                title = "Quick Links";
                groups = lib.optionals (urlStyle == "internal") [
                  {
                    title = "Infrastructure";
                    links = [
                      {
                        title = "Proxmox VE";
                        url = "https://192.168.68.222:8006";
                        icon = "mdi:server";
                      }
                      {
                        title = "NAS";
                        url = urls.glance;
                        icon = "mdi:nas";
                      }
                      {
                        title = "Nginx Proxy Manager";
                        url = "http://192.168.68.93:81";
                        icon = "mdi:server-network";
                      }
                      {
                        title = "n8n";
                        url = "https://192.168.68.70";
                        icon = "si:n8n";
                      }
                      {
                        title = "Gitea";
                        url = urls.gitea;
                        icon = "si:gitea";
                      }
                    ];
                  }
                ] ++ [
                  {
                    title = "Media & Entertainment";
                    links = [
                      {
                        title = "Jellyfin";
                        url = urls.jellyfin;
                        icon = "si:jellyfin";
                      }
                      {
                        title = "Jellyseerr";
                        url = urls.jellyseerr;
                        icon = "mdi:jellyfish";
                      }
                      {
                        title = "Navidrome";
                        url = urls.navidrome;
                        icon = "mdi:music";
                      }
                    ] ++ lib.optionals (urlStyle == "internal") [
                      {
                        title = "Bonob (Sonos)";
                        url = urls.bonob;
                        icon = "mdi:speaker";
                      }
                      {
                        title = "Sonarr";
                        url = urls.sonarr;
                        icon = "si:sonarr";
                      }
                      {
                        title = "Radarr";
                        url = urls.radarr;
                        icon = "si:radarr";
                      }
                      {
                        title = "Bazarr";
                        url = urls.bazarr;
                        icon = "mdi:message";
                      }
                      {
                        title = "Prowlarr";
                        url = urls.prowlarr;
                        icon = "mdi:magnify";
                      }
                      {
                        title = "qBittorrent";
                        url = urls.qbittorrent;
                        icon = "si:qbittorrent";
                      }
                      {
                        title = "Koito";
                        url = "http://${hostIP}:4110";
                        icon = "mdi:account-music";
                      }
                    ];
                  }
                ] ++ lib.optionals (urlStyle == "internal") [
                  {
                    title = "Home Automation";
                    links = [
                      {
                        title = "Homebridge";
                        url = "http://192.168.68.79:8581";
                        icon = "mdi:home-automation";
                      }
                      {
                        title = "Scrypted";
                        url = "https://192.168.68.69:10443";
                        icon = "mdi:cctv";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      }
    ] ++ lib.optionals (urlStyle == "internal") [
      {
        name = "All Services";
        columns = [
          {
            size = "full";
            widgets = [
              {
                type = "monitor";
                title = "Infrastructure & Management";
                cache = "30s";
                sites = [
                  {
                    title = "Proxmox VE";
                    url = "https://192.168.68.222:8006";
                    icon = "mdi:server";
                    allow-insecure = true;
                  }
                  {
                    title = "NAS";
                    url = urls.glance;
                    icon = "mdi:nas";
                  }
                  {
                    title = "Nginx Proxy Manager";
                    url = "http://192.168.68.93:81";
                    icon = "mdi:server-network";
                  }
                  {
                    title = "Glance";
                    url = urls.glance;
                    icon = "mdi:view-dashboard";
                  }
                  {
                    title = "n8n";
                    url = "https://192.168.68.70";
                    icon = "si:n8n";
                    allow-insecure = true;
                  }
                  {
                    title = "Gitea";
                    url = urls.gitea;
                    icon = "si:gitea";
                  }
                ];
              }
              {
                type = "monitor";
                title = "Home Automation";
                cache = "30s";
                sites = [
                  {
                    title = "Homebridge";
                    url = "http://192.168.68.79:8581";
                    icon = "mdi:home-automation";
                  }
                  {
                    title = "Scrypted";
                    url = "https://192.168.68.69:10443";
                    icon = "mdi:cctv";
                    allow-insecure = true;
                  }
                ];
              }
            ];
          }
          {
            size = "full";
            widgets = [
              {
                type = "monitor";
                title = "Media & Entertainment";
                cache = "30s";
                sites = [
                  {
                    title = "Jellyfin";
                    url = urls.jellyfin;
                    icon = "si:jellyfin";
                  }
                  {
                    title = "Jellyseerr";
                    url = urls.jellyseerr;
                    icon = "mdi:jellyfish";
                  }
                  {
                    title = "Navidrome";
                    url = urls.navidrome;
                    icon = "mdi:music";
                  }
                  {
                    title = "Bonob (Sonos)";
                    url = urls.bonob;
                    icon = "mdi:speaker";
                  }
                  {
                    title = "Sonarr";
                    url = urls.sonarr;
                    icon = "si:sonarr";
                  }
                  {
                    title = "Radarr";
                    url = urls.radarr;
                    icon = "si:radarr";
                  }
                  {
                    title = "Bazarr";
                    url = urls.bazarr;
                    icon = "mdi:message";
                  }
                  {
                    title = "Prowlarr";
                    url = urls.prowlarr;
                    icon = "mdi:magnify";
                  }
                  {
                    title = "qBittorrent";
                    url = urls.qbittorrent;
                    icon = "si:qbittorrent";
                  }
                  {
                    title = "Koito";
                    url = "http://${hostIP}:4110";
                    icon = "mdi:account-music";
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
  };
in
glanceConfig