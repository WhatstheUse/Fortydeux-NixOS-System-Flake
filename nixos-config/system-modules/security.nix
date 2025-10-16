{ config, pkgs, lib, ... }:

let
  sessionCfg = config.sessionProfiles or { };
  swaylockConsumers =
    (sessionCfg.sway.enable or false)
    || (sessionCfg.niri.enable or false)
    || (sessionCfg.river.enable or false)
    || (sessionCfg.wayfire.enable or false);
in
{ # Security.nix

  # Security
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;
  security.doas.enable = false;

  # Services - swaylock (pam).
  security.pam.services = {
    login = {
      limits = [
        { domain = "*"; type = "soft"; item = "nofile"; value = "4096"; }
        { domain = "*"; type = "hard"; item = "nofile"; value = "8192"; }
      ];
    };
  };
  security.pam.services.swaylock = lib.mkIf swaylockConsumers {};

  # Services - Mullvad VPN
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  #Services - clamav updater: freshclam
  services.clamav.updater.enable = true;

  environment.systemPackages = with pkgs; [
    clamav
    wireguard-tools
  	mullvad-vpn
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
   networking.firewall.allowedTCPPorts = [ 4242 24800 24802 42457 ];
   networking.firewall.allowedUDPPorts = [ 4242 24800 24802 42457 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
    
}
