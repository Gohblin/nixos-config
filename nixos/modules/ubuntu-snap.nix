{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
 
  users.users.joshua.extraGroups = [ "docker" ];
 
  virtualisation.oci-containers.containers.ubuntu-snap = {
    image = "ubuntu:latest";
    
    # Install snap during container creation
    cmd = [
      "/bin/bash"
      "-c"
      ''
        apt-get update && \
        apt-get install -y snapd && \
        sleep infinity
      ''
    ];
    
    # Required for snap to work properly
    extraOptions = [
      "--privileged"
      "--security-opt" "apparmor=unconfined"
      "--security-opt" "seccomp=unconfined"
    ];
    
    volumes = [
      "/var/lib/snapd:/var/lib/snapd"
      "/snap:/snap"
    ];
  };
}
