{ config, pkgs, lib, ... }:

{
  # Create smbusers group
  users.groups.smbusers = {};
  
  # Add existing kristian user to smbusers group
  users.users.kristian = {
    extraGroups = [ "smbusers" ];
  };
  
}