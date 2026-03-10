###############################################################################
# User account
###############################################################################
{ config, pkgs, inputs, lib, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tim = {
    hashedPasswordFile = config.sops.secrets."user_password".path;
    isNormalUser = true;
    extraGroups = [ "wheel" "wireshark" "docker" "vboxusers" "libvirtd" "games" "gamemode" "video" "jackaudio" "kvm" "corectrl" "lact" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      wayvr
    ];
  };

  systemd.user.slices."user-${builtins.toString config.users.users.tim.uid}.slice".sliceConfig = {
    CPUQuota = "50%";
    MemoryMax = "32G";
    MemoryHigh = "30G";
    TasksMax = "8192";  # Prevent fork bombs
    IOWeight = "100";   # Prevent I/O starvation
  };

  sops.secrets."user_password" = {
    neededForUsers = true;
  };
}
