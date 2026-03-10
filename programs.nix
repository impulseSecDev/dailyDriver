###############################################################################
# Programs
###############################################################################
{ config, pkgs, ... }:

{
  programs.java.enable = true;

  programs.nix-ld.enable = true;

  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };  

  hardware.steam-hardware.enable = true;

  programs.gamemode.enable = true;

  programs.coolercontrol.enable = true;

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-source-clone
      obs-shaderfilter
      obs-move-transition
    ];
    enableVirtualCamera = true;
  };

  programs.nano.enable = false;
  programs.neovim.defaultEditor = true;
  # Programs that require SUID wrappers or special user config
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
