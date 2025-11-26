# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
# export LC_ALL=en_IN.UTF-8
# export LANG=en_IN.UTF-8

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="bira"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)
#
# source $ZSH/oh-my-zsh.sh
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh
source_if_exists() {
    [ -r "$1" ] && source "$1"
}

source_if_exists ~/.dotfiles/dots/zsh/aliases.zsh           # aliases
source_if_exists ~/.dotfiles/dots/zsh/nix-specific-fns.zsh  # Nix only functions

# Custom Functions
mcd ()
{
    mkdir $1;
    cd $1;
}

sd() {
    CACHE_FILE=~/.cache/fzf_cache/.fzf_dir_cache.txt

    # Ensure the cache file exists
    mkdir -p ~/.cache/fzf_cache
    touch "$CACHE_FILE"

    if [[ "$1" == "-all" ]]; then
        # Find all directories starting from $HOME, excluding the 'windows' directory
        echo "Finding all directories (excluding 'windows') and updating the cache..."
        # find "$HOME" -path "$HOME/windows" -prune -o -type d -print 2>/dev/null | sed "s|$HOME|~|" >> "$CACHE_FILE"
        fd --type d --exclude windows . "$HOME" | sed "s|$HOME|~|" >> "$CACHE_FILE"

        # Remove duplicates and sort the cache
        sort -u "$CACHE_FILE" -o "$CACHE_FILE"

        echo "Cache updated with all directories found, excluding 'windows'."
        return 0
    fi

    # Default behavior: Select and cd into a directory from the cache
    if [[ -s "$CACHE_FILE" ]]; then
        echo "Selecting a directory from cache..."
        selected_dir=$(cat "$CACHE_FILE" | fzf)

        if [[ -n "$selected_dir" ]]; then
            # Convert ~/ back to $HOME for `cd`
            target_dir=$(echo "$selected_dir" | sed "s|^~|$HOME|")
            echo "Changing directory to: $target_dir"
            cd "$target_dir" || echo "Failed to change directory."
        else
            echo "No directory selected."
        fi
    else
        echo "Cache is empty. Use 'sd -all' to populate it."
    fi
}

#searches for a term and lets you select the exact match and open the file and take you to the exact match
rgs() {
    if [ -z "$1" ]; then
        echo "Usage: rgs <search_term>"
        return 1
    fi

    local search_term="$1"
    local selected_match

    # Search for the term with rg; each line is output as: file:line:...
    selected_match=$(rg --line-number --color=always "$search_term" | \
        fzf --ansi --delimiter : \
            --preview "rg --color=always -C10 --line-number '$search_term' {1}" \
            --preview-window=up:20:wrap)

    if [ -n "$selected_match" ]; then
        local file
        local line
        file=$(echo "$selected_match" | cut -d: -f1)
        line=$(echo "$selected_match" | cut -d: -f2)

        # Open the file in Neovim at the matched line.
        nvim +"$line" "$file"
    fi
}

cdbin() {
    cd $(dirname $(readlink -f $(which $1)))
}

enter_debian() {
    sudo systemd-nspawn -D ~/Strong-Containers/Debian-13 --user=quun-bin
}

export PATH="/usr/sbin:/sbin:$PATH"
export DOTNET_ROOT="/nix/store/gydpsi918ix7zfa8x6mfh06n4z64qw63-dotnet-sdk-9.0.306/share/dotnet/"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
