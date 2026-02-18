# aliases for mostly CLI based tools
alias lsd="lsd --color=always"
alias l="ll"
alias ls="lsd -hN"
alias ll="lsd -lhN"
alias lla="lsd -lhaN"
alias rgl="rg --color=always --line-number"
alias dush="du -sh *"
alias cls="clear"
alias nrs="sudo nixos-rebuild switch"
alias nsp="nix-shell -p"
alias npi="nix profile install nixpkgs#"
alias hms="home-manager switch"
alias hmsf="home-manager switch --flake /home/quun/.dotfiles/dots/"
alias sr="steam-run"
alias clipb="xclip -selection clipboard"
alias trixie="distrobox enter debian-trixie"
alias appr="appimage-run"

# cd
alias dev="cd ~/Development/"
alias cdhome="cd ~/.config/home-manager"
alias cdnix="cd /etc/nixos"
alias dots="cd ~/.dotfiles/dots"
alias conf="cd ~/.config/"
alias fonts="cd ~/.local/share/fonts"
alias b="cd .."

# yes i made these i know
alias "tree1"="tree -L 1"
alias "tree2"="tree -L 2"
alias "tree3"="tree -L 3"
alias emacs="emacs -fs"

# aliases to open/use programs efficiently
alias "c."="code ."
alias "z."="zeditor ."
alias ds='dolphin . > /dev/null 2>&1 &'
alias clion='clion . > /dev/null 2>&1 &'
alias lgit="lazygit"
alias rr='ranger'
alias vlc='VLC_PLUGIN_PATH=/nix/store/qpx2vagbyra7hdh1zlivq55a4jvc2d9n-vlc-bittorrent-2.15/lib vlc'
# alias mcaselector="sh ~/Games/Minecraft/MCA\ Selector/mcaselector.sh"

# all the configs related aliases
alias nixconf="sudo nvim /etc/nixos/configuration.nix"
alias flakeconf="nvim ~/.config/home-manager/flake.nix"
alias aliasconf="nvim ~/.dotfiles/dots/zsh/aliases.zsh"
alias kittyconf="nvim ~/.dotfiles/dots/kitty/kitty.conf"
alias zshconf="nvim ~/.zshrc"
alias nvimconf="nvim ~/.dotfiles/dots/NixvimLazyvim/flake.nix"
alias hc="nvim ~/.config/home-manager/home.nix"
alias z.home="zeditor ~/.config/home-manager/home.nix"
alias nixfns="nvim ~/.dotfiles/dots/zsh/nix-specific-fns.zsh"
alias so="source ~/.zshrc"
