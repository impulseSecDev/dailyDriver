###############################################################################
#  Environment
###############################################################################
{ config, pkgs, inputs, ... }:

{
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  #For i3
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  # Enable Desktop Environment
  services = {
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };

    xserver = {
      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [
            i3status
            i3lock
            i3blocks
            autotiling
            polybar
            dunst
            picom
          ];
        };
        # qtile = {
        #   enable = true;
        #   extraPackages = python3Packages: with python3Packages; [
        #     qtile-extras
        #   ];
        # };
      };  
    };
  };  
  programs = {
    niri.enable = true;
    xwayland.enable=true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      # Specifically tell Niri to use the GTK portal for most things
      # but GNOME is often needed for the actual screencast backend.
      niri = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ]; # Prevents crashes if Nautilus isn't installed
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.rtkit.enable = true; 
}

