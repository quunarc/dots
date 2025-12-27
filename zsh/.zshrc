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

ranger () {
        local LOGFILE='/tmp/cd_ranger'
        # `command ranger` to launch ranger itself,
        # instead of causing an infinite loop with
        # this function calling itself
        command ranger "$@" || exit $?
        if [[ -f "${LOGFILE}" ]]
        then
                cd "$(cat "${LOGFILE}")"
                rm -f "${LOGFILE}"
        fi
}

# Check if running inside a Distrobox container
if [ -n "$CONTAINER_ID" ] || [ -f "/run/.containerenv" ] || [ -f "/.dockerenv" ]; then
    PS1="%{$(tput setaf 226)%}%n%{$(tput setaf 220)%}@%{$(tput setaf 214)%}trixie %{$(tput setaf 43)%}%1~ %{$(tput sgr0)%}$ "
    if [[ $PWD/ = /home/quun/Containers/debian-trixie/* ]]; then
        cd $PWD
    else
        cd /home/quun/Containers/debian-trixie/
    fi
fi


export PATH="/usr/sbin:/sbin:$PATH"
export PATH="/home/quun/Public/scripts/bin/:$PATH"
export PATH="/home/quun/Softwares/binaries/:$PATH"
export PATH="/home/quun/.config/emacs/bin/:$PATH"


export DOTNET_ROOT="/nix/store/gydpsi918ix7zfa8x6mfh06n4z64qw63-dotnet-sdk-9.0.306/share/dotnet/"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
