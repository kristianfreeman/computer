{ config, pkgs, lib, ... }:

{
  # Create smbusers group
  users.groups.smbusers = {};
  
  # Add existing kristian user to smbusers group
  users.users.kristian = {
    extraGroups = [ "smbusers" ];
  };
  
  # Simple activation script to ensure permissions
  system.activationScripts.sambaSetup = ''
    # Create Time Machine directory
    mkdir -p /valhalla/timemachine
    chown root:smbusers /valhalla/timemachine
    chmod 770 /valhalla/timemachine
    
    # Add media user to smbusers if it exists
    if id media &>/dev/null; then
      usermod -a -G smbusers media || true
    fi
  '';
}