{ config, lib, pkgs, ... }:

{
  imports =
    [ # Esto Sirve para Fragmentar la Configuracion en Distintas Partes.
      # Fragmento Para el Escaneo de los Componentes del PC.
      ./hardware-configuration.nix
    ];

  # Esto Habilita el Cargador de Arranque.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev"; 
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };

  # Le dice a SystemD que no Apague el PC con el Boton de Encendido.
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Esto Define el Nombre del PC en la Red.
  networking.hostName = "NixOS-Vivobook-15"; 
  # networking.hostName = "NixOS-Latitude-7280";

  # Habilita el Servicio Network Manager.
  networking.networkmanager.enable = true;

  # Habilita el Servicio de Tailscale VPN
  services.tailscale.enable = true;
  
  # Habilita el Servicio Bluetooth.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Habilita el Servicio de Montaje de Discos
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  
  # Esto Establece tu Zona Horaria.
  time.timeZone = "Europe/Madrid";

  # Esta parte sirve para Establecer el Idioma, Distribucion del Teclado, etc.
  i18n.defaultLocale = "es_ES.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
   };

  # Esto Configura el Teclado.
  services.xserver.xkb = {
    layout = "es";
    variant = "";
   };

  console = {
    keyMap = "es";
   };

  # Esto Habilita el Servicio "Wayland" y Instala el Window Manager,
  # Sin esto puede pasar que no puedas Iniciar Sesion Graficamente.
  services.displayManager.ly = {
    enable = true;
  };

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Instala Drivers Graficos y Habilita la Aceleracion Grafica.
  hardware.graphics = {
    enable = true;
    enable32Bit = true; 
  };

  # Esto Habilita el servicio Polkit base del sistema.
  security.polkit.enable = true;

  # Esto Crea un servicio de usuario en SystemD para lanzar el agente gráfico de MATE.
  systemd.user.services.mate-polkit-authentication-agent = {
    description = "MATE Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
    Restart = "on-failure";
    RestartSec = 1;
    TimeoutStopSec = 10;
    };
  };

  # Esto Habilita la Virtualizacion.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Esto Habilita el Servicio del Sonido. 
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Esto define tu Usuario.
  users.users.antsoftware21 = {
    isNormalUser = true;
    description = "Antsoftware21";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" "podman" "adbusers" ];

    # Rangos de subUID y subGID para contenedores rootless
    subUidRanges = [ { count = 65536; startUid = 100000; } ];
    subGidRanges = [ { count = 65536; startGid = 100000; } ];
  };

  # Esto permite Instalar Paquetes No-Libres.
  nixpkgs.config.allowUnfree = true;

  # Habilita Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true; 
  };

  # Esta es la Lista de los Programas que quieras Instalar.
  # Simplemente dentro de las Llaves pones el Programa,
  # Luego pones en la terminal sudo nixos-rebuild switch y ya lo tendrias instalado.
  # Recomendable Reiniciar el PC despues de Instalar un Programa, por si acaso.
  environment.systemPackages = with pkgs; [

    # Programas del Entorno (NO TOCAR), a no ser que sepas lo que haces :
    rofi
    rofi-power-menu
    waybar
    swayidle
    swaylock-effects
    nwg-look
    papirus-icon-theme
    tokyonight-gtk-theme
    graphite-cursors
    pulsemixer
    bluetuith
    foot
    nemo
    engrampa
    zip
    unzip
    eom

    # Programas Miscelaneos :
    fastfetch
    nyancat
    git
    curl
    wget
    htop
    btop
    cava
    podman
    distrobox
    nicotine-plus
   
    # Mis Programas :
    vivaldi
    vesktop
    telegram-desktop
    obs-studio
    nocturne
    filezilla
    vlc
    kdePackages.kdenlive
    vscodium
    obsidian
    libresprite
    virt-manager
    android-tools
    ];

  # Aqui van las Fuentes Tipograficas que quieras.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    ];

  # Lista de Servicios Extra (Puedes agregar Otros):

    # Habilita el Servicio SSH.
    services.openssh.enable = true; 

    # Habilita el Servicio para Imprimir en Impresora.
    services.printing.enable = true;

    # Habilita el Servicio Flatpak.
    services.flatpak.enable = true;

    # Habilita el Servicio de los Perfiles de Potencia
    services.power-profiles-daemon.enable = true;

  # Aqui Habia un Comentario Gigante, Lo que queria decir, NO TOQUES ESTO XD.
  system.stateVersion = "26.05";
}

