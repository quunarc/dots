# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  lanzaboote-src = builtins.fetchTarball {
    url = "https://github.com/nix-community/lanzaboote/archive/v0.4.2.tar.gz";
    sha256 = "0xc1wawnb0297h5khxblmf9pd1fry950xkcm7mwlck19s2906h80"; # Use a dummy or correct hash
  };
  lanzaboote = import lanzaboote-src;

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      /home/quun/System/musnix

      lanzaboote.nixosModules.lanzaboote
    ];

  musnix.enable = true;

  boot.blacklistedKernelModules = [ "hid-nintendo" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  # 2. Enable Lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl/";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  # boot.binfmt.emulatedSystems = [ "i386-linux" ];

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  systemd.settings.Manager = {
    DefaultLimitNOFILE=524288;
  };

  security.pam.loginLimits = [{
      domain = "quun";
      type = "hard";
      item = "nofile";
      value = "524288";
  }];


  nixpkgs.overlays = lib.singleton (final: prev: {
    kdePackages = prev.kdePackages // {
      plasma-workspace = let

        # the package we want to override
        basePkg = prev.kdePackages.plasma-workspace;

        # a helper package that merges all the XDG_DATA_DIRS into a single directory
        xdgdataPkg = pkgs.stdenv.mkDerivation {
          name = "${basePkg.name}-xdgdata";
          buildInputs = [ basePkg ];
          dontUnpack = true;
          dontFixup = true;
          dontWrapQtApps = true;
          installPhase = ''
            mkdir -p $out/share
            ( IFS=:
              for DIR in $XDG_DATA_DIRS; do
                if [[ -d "$DIR" ]]; then
                  cp -r $DIR/. $out/share/
                  chmod -R u+w $out/share
                fi
              done
            )
          '';
        };

        # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
        # script and instead inject the path of the above helper package
        derivedPkg = basePkg.overrideAttrs {
          preFixup = ''
            for index in "''${!qtWrapperArgs[@]}"; do
              if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                unset -v "qtWrapperArgs[$((index+0))]"
                unset -v "qtWrapperArgs[$((index+1))]"
                unset -v "qtWrapperArgs[$((index+2))]"
                unset -v "qtWrapperArgs[$((index+3))]"
              fi
            done
            qtWrapperArgs=("''${qtWrapperArgs[@]}")
            qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
            qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
          '';
        };

      in derivedPkg;
    };
  });

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 3*1024; # 3 GB
  }];

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # hardware.xone.enable = true;

  # ------------------ NVIDIA DRIVER ----------------------

  # Enable OpenGL
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    nvidiaBusId = "PCI:1:0:0";
    amdgpuBusId = "PCI:5:0:0";
  };

  # -----------------------------------------------------


  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  # SDDM
  services.displayManager.sddm.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    # Configure WirePlumber to disable suspend
    wireplumber.extraConfig = {
      "10-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                # Match all alsa sinks and sources
                "node.name" = "~alsa_input.*";
              }
              {
                "node.name" = "~alsa_output.*";
              }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
                "node.always-process" = true;
              };
            };
          }
        ];
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  services.xserver.xkb.layout = "us";

  services.flatpak.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.quun = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" "fuse" "networkmanager" "docker" "libvirtd" ]; # wheel Enables ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.zsh;
    home = "/home/quun";
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
      };
  };

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
  };

  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "bira";
  };

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.kdeconnect.enable = true;

  programs.steam = {
    enable = true;
  };


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [

    # Editors
    vim

    # CLI tools
    wget curl tldr docker home-manager lshw mesa-demos tailscale

    # system
    networkmanager distrobox efibootmgr
    javaPackages.compiler.temurin-bin.jre-25
    gcc nodejs_24

    # important libraries
    nix-ld
    patchelf
    clang
    clang-tools
    file
    # build systems
    cmake gnumake scons pkg-config
  ];

  # Services
  services.tailscale.enable = true;

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    glibc
    stdenv.cc.cc
    clang
    clang-tools
    sdl3
    # pkgsi686Linux.stdenv.cc.cc
    # pkgsi686Linux.glibc

    icu
    zlib
    openssl
    libxml2
    curl
    libpng
    libjpeg
    expat
    alsa-lib
    mesa
    gtk3
    udev
    dbus
    fontconfig
    freetype
    # both fuse versions are needed keep them both
    fuse3
    fuse2

    #xorg libs
    libx11
    libxi
    libxext
    libxinerama
    libxrandr
    libxrender
    libxcursor
    libxfixes

    libGL
    libGLU
    vulkan-loader

    pulseaudio

    libogg
    libvorbis
    libopus

    wayland
    libxkbcommon
  ];

  environment.etc = {
  # 64-bit loader for 64-bit binaries
  "ld-linux-x86-64.so.2".source =
    "${pkgs.stdenv.cc.cc}/lib/ld-linux-x86-64.so.2";

  # 32-bit loader for 32-bit binaries
  "ld-linux.so.2".source =
    "${pkgs.pkgsi686Linux.stdenv.cc.cc}/lib/ld-linux.so.2";
  };

  # boot.loader.grub.device = "nodev";

  fileSystems."/boot" = {
      device = "/dev/nvme0n1p1";
      fsType = "vfat";
  };

  security.sudo.extraConfig = ''
    quun ALL=(ALL) NOPASSWD: /home/quun/.nix-profile/bin/ydotool
    quun ALL=(ALL) NOPASSWD: /home/quun/.nix-profile/bin/ydotoold
  '';

  security.rtkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.udev.extraRules = ''
  #   ACTION=="add", ATTRS{idVendor}=="11c0", ATTRS{idProduct}=="5505", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 11c0 5505 > /sys/bus/usb/drivers/xpad/new_id'"
  # '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

# Make sure 'lib' is available in your arguments at the top of the file 
# e.g., { config, pkgs, lib, ... }:

specialisation = {
  x11.configuration = {
    services.xserver.enable = true;
    services.displayManager.sddm.wayland.enable = lib.mkForce false;

    # Force ONLY nvidia — no amdgpu in X at all
    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        # Reverse sync: NVIDIA renders AND drives the display
        # AMD is only used to hand off the signal to the panel/ports
        reverseSync.enable = lib.mkForce true;
        
        # These must be off when using reverseSync
        offload.enable = lib.mkForce false;
        offload.enableOffloadCmd = lib.mkForce false;
        sync.enable = lib.mkForce false;

        nvidiaBusId = "PCI:1:0:0";
        amdgpuBusId = "PCI:5:0:0";
      };
    };

    # These two together ensure nvidia-drm is loaded before X starts
    # and claims the framebuffer before amdgpu does
    boot.kernelParams = lib.mkForce [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    # Blacklist amdgpu from doing anything display-related in this specialisation
    boot.blacklistedKernelModules = [ "amdgpu" ];
  };
};

}

