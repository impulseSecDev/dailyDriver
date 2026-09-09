{ config, pkgs, lib, ... }:

{
  imports = [
    #./neovim.nix
    ./vrc-status.nix
    #./monado.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "25.05";

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic"; # Or the name of your chosen theme
    size = 14;
  };

  programs.bash.shellAliases = {
  sops-edit = "sudo SOPS_AGE_KEY_FILE=/home/tim/.config/sops/age/keys.txt sops";
};

home.sessionVariables = {
  MOZ_ENABLE_WAYLAND = "0";
};

  #===============================================================
  #PROGRAMS
  #===============================================================
  programs.qutebrowser = {
    enable = true;
    settings = {
      fonts.hints = "bold 25pt monospace";
      content.blocking.method = "both";
      auto_save.session = true;
    };
    keyBindings = {
      normal = {
        "<F1>" = "hint links spawn --detach mpv {hint-url}";
        "<F2>" = "spawn --detach mpv {url}";
      };
    };
  };
    

  #==================================================================================
  #SERVICES
  #==================================================================================

  #======================================================================================
  #PACKAGES
  #======================================================================================
  home.packages = with pkgs; [
    # --- TERMINAL UTILITIES & CORE CLI TOOLS ---
    axel
    cmatrix
    fastfetch
    fd
    findutils
    fzf
    glow # view markdown in the terminal
    hollywood
    httpie # replace curl for cleaner jq like output
    jq
    kitty
    lsd
    ncdu
    ripgrep
    speedtest-cli
    sops
    tree
    tty-clock # terminal clock
    wl-clipboard
    youtube-tui
    zoxide

    # --- DEVELOPMENT, EDITORS & LANGUAGE SERVERS ---
    bash-language-server
    devbox
    godot
    lua-language-server
    marksman
    nil
    nodejs
    opencode
    pyright
    stylua
    typescript-language-server
    via #keyboard configuration
    web-ext # manage & sign browser extensions

    # --- WAYLAND ENVIRONMENT, WINDOW MANAGEMENT & RICE UTILITIES ---
    awww
    brightnessctl
    dunst
    fuzzel # fzf app picker for wayland
    gradia # screenshot tool
    nwg-drawer
    rofi
    swaybg
    swaybg
    waybar
    waypaper
    wayvr
    xwayland-satellite

    # --- WEB BROWSERS & INTERNET TOOLS ---
    brave
    chromium
    firefox
    tor-browser
    vivaldi

    # --- SYSTEM ADMINISTRATION, HARDWARE MONITORING & DISK MANAGEMENT ---
    cpuset
    dnsmasq
    exfatprogs
    file-roller
    fwknop
    gnome-disk-utility
    gparted
    guestfs-tools
    libguestfs
    liquidctl
    nvtopPackages.amd
    openvpn
    oprofile
    proton-vpn
    qemu
    radeontop
    stress-ng
    tlrc
    wireguard-tools
    OVMFFull

    # --- VIRTUALIZATION, CONTAINERS & GAMING ---
    bs-manager
    distrobox
    furmark
    intiface-central
    openvr
    prismlauncher
    rustdesk-flutter
    unityhub
    vrc-get
    vrcx
    winetricks

    # --- MULTIMEDIA, CREATIVE & OFFICE APPLICATIONS ---
    anki
    bitwarden-cli
    bitwarden-desktop
    burpsuite
    easyeffects
    gh
    gnome-pomodoro
    gnome-software
    grim #screenshot tool
    impression
    keepass
    libreoffice-fresh
    mediawriter
    mousam
    mpv
    nautilus
    #osc.packages.${pkgs.system}.default
    obsidian
    pdfarranger
    postman
    pulseaudio
    ranger
    satty #image editor used with screenshot tool
    shotwell
    slurp # used with screenshot tool
    teams-for-linux
    thunderbird
    vlc
    xmind
    yt-dlp

    # --- TERMINAL MULTIPLEXING & SECURITY ---
    nmap
    tmux
  ];

  #======================================================================================
  #ALACRITTY TERMINAL CONFIGURATION
  #======================================================================================
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrains Mono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrains Mono Nerd Font";
          style = "Bold Italic";
        };
        size = 12;
      };
      
      env = {
        TERM = "alacritty";
      };
      
      window = {
        opacity = 0.95;
        blur = true;
        padding = {
          x = 6;
          y = 6;
        };
      };
      
      colors = {
        primary = {
          background = "#212337";
          foreground = "#ebfafa";
        };
        normal = {
          black = "#37384d";
          red = "#f16c75";
          green = "#04d1f9";
          yellow = "#f1fc79";
          blue = "#7081d0";
          magenta = "#a48cf2";
          cyan = "#04d1f9";
          white = "#ebfafa";
        };
        bright = {
          black = "#323449";
          red = "#f16c75";
          green = "#04d1f9";
          yellow = "#f1fc79";
          blue = "#7081d0";
          magenta = "#a48cf2";
          cyan = "#04d1f9";
          white = "#ebfafa";
        };
      };
      
      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };
        blink_interval = 500;
      };
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
