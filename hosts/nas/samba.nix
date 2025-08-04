{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    
    settings = {
      global = {
        # Basic server settings
        workgroup = "WORKGROUP";
        "server string" = "NAS Samba Server";
        "netbios name" = "nas";
        
        # Security settings
        security = "user";
        "encrypt passwords" = "yes";
        "passdb backend" = "tdbsam";
        
        # Performance tuning
        "socket options" = "TCP_NODELAY SO_RCVBUF=524288 SO_SNDBUF=524288";
        "use sendfile" = "yes";
        
        # macOS compatibility and Time Machine
        "min protocol" = "SMB2";
        "ea support" = "yes";
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:time machine" = "yes";
        
        # Disable printing
        "load printers" = "no";
        printing = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";
        
        # Authentication settings
        "map to guest" = "never";
        "guest account" = "nobody";
        "invalid users" = [ "root" ];
      };
      
      # General media share - read/write for authenticated users
      media = {
        path = "/valhalla/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "media";
        comment = "Media Files";
        "valid users" = "@smbusers";
        "write list" = "@smbusers";
      };
      
      # Downloads share - read/write for authenticated users
      downloads = {
        path = "/valhalla/downloads";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "media";
        comment = "Downloads";
        "valid users" = "@smbusers";
        "write list" = "@smbusers";
      };
      
      # Backup share for Time Machine
      backups = {
        path = "/valhalla/backups";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "force group" = "smbusers";
        comment = "Backups";
        "valid users" = "@smbusers";
        "write list" = "@smbusers";
      };
      
    };
  };
  
  # Create necessary directories and set permissions
  systemd.tmpfiles.rules = [
    "d /valhalla/backups 0770 kristian smbusers -"
  ];
  
  # Create smbusers group
  users.groups.smbusers = {};
  
  # Avahi for service discovery (already enabled in your config)
  services.avahi = {
    publish = {
      enable = true;
      userServices = true;
    };
    # Advertise SMB shares
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=Xserve</txt-record>
          </service>
        </service-group>
      '';
    };
  };
}