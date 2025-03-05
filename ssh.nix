{ config, lib, pkgs, ... }:

{
  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      # Permit root login using password authentication (consider changing this to "no" for production)
      PermitRootLogin = "yes";
      
      # Allow password authentication (consider using key-based authentication instead)
      PasswordAuthentication = true;
      
      # Enable public key authentication
      PubkeyAuthentication = true;
    };
    
    # Optional: Open ports in the firewall
    openFirewall = true;
    
    # Optional: Set the port (default is 22)
    # port = 22;
  };
  
  # Ensure the SSH service starts after the network is up
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  
  # Optional: Configure users allowed to SSH (uncomment and modify as needed)
  # users.users.youruser = {
  #   openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your_key_here"
  #   ];
  # };
}
