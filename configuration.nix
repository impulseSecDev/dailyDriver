###############################################################################
# Configuration.nix
###############################################################################

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user.nix
      ./networking.nix
      ./virtualization.nix
      ./environment.nix
      ./services.nix
      ./programs.nix
      ./wireguard.nix
      ./fluent-bit.nix
      ./wazuh-agent.nix
      ./ai.nix
      ./nginx.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot"; # ← use the same mount point here.
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Extra Kernel Modules - v4l2loopback
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = lib.mkForce [
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  networking.hostName = "PlayWasHere"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Detroit";
  services.ntp.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  boot.blacklistedKernelModules = [ "nvidia" ];
  boot.kernelModules = [
    "v4l2loopback"
  ];

  # Improve memory performance for games & Windows applications using Wine/Proton
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

 # Shorten reboot time by reducing process timeout
 systemd.user.extraConfig = ''DefaultTimeoutStopSec=10s'';

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  security.polkit.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true; # Enable Vulkan and GPU support
    enable32Bit = true;
  };

  hardware.amdgpu.overdrive.enable = true; #enable OC with AMD
  hardware.amdgpu.opencl.enable = true; 

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable sound and Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig = {
      pipewire-pulse = {
        pulse.min.quantum = "1024/48000";
      };
    };

    #vr audio fix
    wireplumber.extraConfig."99-alsa-period-size-rules" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            # This matches the value of the 'node.name' property of the node.
            {
              "node.name" = "~alsa_output.*";
            }
          ];
          actions = {
            # Apply all the desired node specific settings here.
            "update-props" = {
              "api.alsa.period-size" = 1024;
              "api.alsa.headroom" = 8192;
            };
          };
        }
      ];  
    };
  };  

  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
    loopback.enable = true;
  };

  # Disable root password
  users.users.root.hashedPassword = "!";

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    pavucontrol
    networkmanagerapplet
    btop
    gitFull
    usbutils
    coreutils-full
    udiskie
    zip
    unzip
    bat
    eza
    playerctl
    nix-index
    busybox
    lxqt.lxqt-policykit
    polkit_gnome
    cloudflared
  ];

  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira
    nerd-fonts.zed-mono
    nerd-fonts.ubuntu-sans
    nerd-fonts.ubuntu-mono
    nerd-fonts.hack
    nerd-fonts.victor-mono
    nerd-fonts.jetbrains-mono
  ];

  # Uncomment if Bluetooth needed
  # services.blueman.enable = true;
  # hardware.bluetooth.enable = true;
  # hardware.bluetooth.powerOnBoot = true;


  fonts.fontDir.enable = true;

  nix.settings.auto-optimise-store = true;

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/keys.txt";
  };  

  environment.shellAliases = {
    sops-edit = "sudo SOPS_AGE_KEY_FILE=/home/tim/.config/sops/age/keys.txt sops";
  };
  
  # Preserve installation stateVersion comments
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

