{
  config,
  pkgs,
  systems,
  inputs,
  ...
}:

# let
# pkgs-stable = import (builtins.fetchTarball {
#     url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
#     sha256 = "1z0hb7pxqpn142wxcznd31zm0zflbim0cmfcxvmrrn9zgxdg2bfw";
# }) {
#     system = pkgs.system;
#     config = { allowUnfree = true; };
# };
# in
{
  home.username = "quun";
  home.homeDirectory = "/home/quun";

  # DONT CHANGE THIS
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Imports
  # imports = [
  # 	inputs.lazyvim.homeManagerModules.default
  # ];

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    (writeShellScriptBin "nvidia-offload" ''
      	export __NV_PRIME_RENDER_OFFLOAD=1
      	export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      	export __GLX_VENDOR_LIBRARY_NAME=nvidia
      	export __VK_LAYER_NV_optimus=NVIDIA_only
      	exec "$@"
    '')
    #---------------------------------------------------------------------

    # Programs
        # Browser
        firefox
        syncthing

        # Engines
        godot-mono
        godot

        # Art
        krita
        aseprite
        gimp

        # Productivity
        obsidian

        # Utilities
        qdirstat
        qbittorrent
        easyeffects
        bitwarden-desktop
        nicotine-plus
        mediasynclite
        strawberry

        # Games
        lutris
        # pkgs-stable.steam
        protonup-rs
        protonup-qt
        wine64
        steam-run
        bottles

        # Media
        supersonic
        vlc
        vlc-bittorrent
        supercollider
        vital
        carla

    filen-desktop
    telegram-desktop

    # Flake packages
    inputs.zen.packages.${systems}.default # Zen Browser
    inputs.nix-alien.packages.${systems}.default
    inputs.kwin-effects-glass.packages.${systems}.default

    # Editors
    neovim
    emacs
    zed-editor
    jetbrains.idea-community-bin

    #LSP
    inputs.csharplsp.packages.${systems}.default # Csharp LSP
    nixd
    nil
    lua-language-server
    asm-lsp
    pyright
    vimPlugins.scnvim
    rust-analyzer

    # Python packages

    # Terminals
    kitty
    tmux

    # CLI tools
    git
    lazygit
    jujutsu
    ranger
    btop
    dipc
    rclone
    lux
    zoxide
    fzf
    ripgrep
    desktop-file-utils
    television
    chezmoi
    fd
    lsd
    nodePackages_latest.fkill-cli
    steam-run
    bat
    openssl
    pinentry-all
    steghide
    ffmpeg
    qemu_kvm
    rar
    xclip
    lazydocker
    clifm

    #------------------------ LOW ---------------------------
    #graphics
    glfw
    freerdp
    ncurses

    # CONTAINERIZATION
    debootstrap
    firejail

    # hacking
    ghidra-bin
    radare2
    cutter

    nasm    # assembly compiler

    # Misc
    ydotool

    dotnetCorePackages.sdk_9_0-bin
    clang-tools

    #------------------------ END ---------------------------
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionPath = [
    "/home/quun/Public/scripts/"
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/quun/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };


}
