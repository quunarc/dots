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
    # Custom
        (writeShellScriptBin "project-init" ''
            exec ${pkgs.python3}/bin/python3 /home/quun/.dotfiles/dots/scripts/cpp-init/project-init.py "$@"
        '')

    # Programs
        # Browser
        firefox
        syncthing

        # Engines
        inputs.latest-nixpkgs.legacyPackages.${system}.godot
        inputs.latest-nixpkgs.legacyPackages.${system}.godot-mono
        # godot
        renderdoc

        # Art
        krita
        aseprite
        blender
        inkscape
        gimp

        # Productivity
        obsidian
        anki

        # Utilities
        qdirstat
        inputs.latest-nixpkgs.legacyPackages.${system}.qbittorrent-enhanced
        easyeffects
        nicotine-plus
        mediasynclite
        strawberry
        obs-studio
        gearlever
        gpu-screen-recorder-gtk
        proton-vpn
        sshfs

        # Games
        # lutris
        prismlauncher-unwrapped
        modrinth-app-unwrapped
        mcaselector
        protonup-rs
        protonup-qt
        steam-run
        ckan
        vesktop
        lutris-unwrapped

        # Emulation
        retroarch
        azahar

        # Media
        supersonic
        vlc
        vlc-bittorrent
        supercollider
        vital
        carla
        tauon
        cardinal     # cardinal vcv rack
        crosspipe       # audio pipeline graph
        picard
        kdePackages.kdenlive
        davinci-resolve

    filen-desktop
    telegram-desktop
    megasync

    inputs.zen.packages.${systems}.default # Zen Browser
    # inputs.nix-alien.packages.${systems}.default
    inputs.kwin-effects-forceblur.packages.${systems}.x11
    inputs.my-nvim.packages.${systems}.default

    # Editors / IDEs
    # neovim
    zed-editor-fhs
    jetbrains.idea
    jetbrains.clion
    vscode

    # Neovim plugins
        # LSP
        # inputs.csharplsp.packages.${systems}.default # Csharp LSP
        nixd
        nil
        lua-language-server
        asm-lsp
        pyright
        glslls

    # vimPlugins.scnvim

    # Python packages
    python3

    # Terminals
    kitty
    tmux

    # CLI tools
    git
    git-crypt
    lazygit
    ranger
    btop
    dipc
    rclone
    lux
    zoxide
    fzf
    ripgrep
    desktop-file-utils
    fd
    lsd
    bat
    steghide
    ffmpeg
    rar
    xclip
    lazydocker
    clifm
    rustup

    #------------------------ LOW ---------------------------
    #graphics
    glfw
    freerdp
    ncurses

    # CONTAINERIZATION
    qemu_kvm
    debootstrap
    firejail
    devenv

    # hacking
    ghidra-bin
    radare2
    cutter

    nasm    # assembly compiler
    kdePackages.kgpg

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
    # QT_PLUGIN_PATH = "$QT_PLUGIN_PATH:${inputs.kwin-effects-better-blur-dx.packages.${pkgs.system}.default}/lib/qt-6/plugins:${inputs.kwin-effects-glass.packages.${pkgs.system}.default}/lib/qt-6/plugins";
    QT_PLUGIN_PATH = "$HOME/.nix-profile/lib/qt-6/plugins:$QT_PLUGIN_PATH";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };


}
