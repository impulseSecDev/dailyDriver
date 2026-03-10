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
      sddm = {
        enable = true;
        wayland.enable = true;
      };
       autoLogin = {
         enable = false;
         user = "tim";
       };
      defaultSession = "none+i3";
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
      common = {
        default = [
          "gtk"
        ];
      };
    };
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.rtkit.enable = true; 
}

