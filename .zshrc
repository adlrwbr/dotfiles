#
#                                     __
#                                    /__\
#                                   /(__)\
#                                  (__)(__)
#
#                             github.com/adlrwbr
#                       Made with ⌛&♥  by Adler Weber
#
# ============================================================================
# ⚙  Package managers ⚙
# ============================================================================

# snap (linux package manager) configuration
export PATH="/var/lib/snapd/snap/bin:$PATH"

# cargo (rust build / package manager) configuartion
source "$HOME/.cargo/env"

# conda (python virtual env / package manager) configuration
source /home/adler/.config/op/plugins.sh
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

# opam (ocaml package manager) configuration
[[ ! -r /home/adler/.opam/opam-init/init.zsh ]] || source /home/adler/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

# pnpm (performant node package manager) configuration
export PNPM_HOME="/home/adler/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# ============================================================================
# ⚙  Oh-my-zsh and themes ⚙
# ============================================================================

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# ZSH_THEME="juanghurtado" # I like this
ZSH_THEME="dpoggi" # I like this

# ZSH_THEME="steeef" # I don't like this because the git icons wait for `git status`
# ZSH_THEME="half-life" # same as above
# ZSH_THEME="robbyrussell" # I don't like this because it shortens the directory name (no full CWD)

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Update oh-my-zsh automatically without asking
zstyle ':omz:update' mode auto

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

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.


# install zsh-syntax-highlighting
OMZ_SYNTAX_HIGHLIGHTING=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
[ -d $OMZ_SYNTAX_HIGHLIGHTING ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $OMZ_SYNTAX_HIGHLIGHTING

# install zsh-history-substring-search
OMZ_HISTORY_SEARCH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
[ -d $OMZ_HISTORY_SEARCH ] || git clone https://github.com/zsh-users/zsh-history-substring-search $OMZ_HISTORY_SEARCH

# install zsh-autosuggestions
OMZ_AUTOSUGGESTIONS=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[ -d $OMZ_AUTOSUGGESTIONS ] || git clone https://github.com/zsh-users/zsh-autosuggestions $OMZ_AUTOSUGGESTIONS
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

plugins=(git zsh-syntax-highlighting zsh-history-substring-search zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# ⚙  fzf  ⚙
# ============================================================================
if command -v fzf &> /dev/null; then
    export FZF_ALT_C_COMMAND='fd --type=directory --hidden --follow --exclude={.git,.bare,.idea,.vscode,__pycache__,.conda,site-packages,.sass-cache,.cargo,deps,go,Pods,.mozilla,.npm,pnpm,.local,.cache,node_modules,build,dist,tmp}'

    source /usr/share/fzf/completion.zsh

    # ctrl-T for files under the current dir
    # ctrl-r for history
    # alt-c to cd into dirs under the current dir
    source /usr/share/fzf/key-bindings.zsh
else
    echo "Warning: fzf not found."
fi

# ============================================================================
# ⚙  Options and misc config  ⚙
# ============================================================================

setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt hist_ignore_dups                                         # ignore duplicated commands history list
setopt autocd                                                   # if only directory path is entered, cd there.
setopt inc_append_history                                       # save commands are added to the history immediately, otherwise only when shell exits.
setopt hist_ignore_space                                          # Don't save commands that start with space
setopt hist_expire_dups_first                                   # delete duplicates first when HISTFILE size exceeds HISTSIZE

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down

# Use vi mode
# set -o vi

# Set EDITOR depending on if session is local/remote session
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# open a file in obsidian using the URL schema support
# Usage `obs file.md`
function obs() {
    local file_url="obsidian://$(realpath "$1")"
    echo $file_url
    # xdg-open "$file_url" >/dev/null 2>&1 & disown
    xdg-open "$file_url" >/dev/null & disown
}

# Git worktree clone
# Sets up a clean worktree directory with all bare files hidden in .bare
function gwtc() {
    if [ "$#" -ne 2 ]; then
        echo "Git worktree clone: clone a repo, set up a worktree dir, check out main"
        echo "Usage: gwtc <repo URL> <directory name>"
        return 1
    fi
    URL="$1"
    DIRNAME="$2"

    mkdir -p $DIRNAME
    git clone --bare $URL "$DIRNAME/.bare"
    echo "gitdir: ./.bare" > "$DIRNAME/.git"
    cd $DIRNAME
    git worktree add main
    cd main
}

# 1Password CLI
source ~/.config/op/plugins.sh

# custom aliases: view all with `alias`
alias sz="source ~/.zshrc"
alias oldvim="NVIM_APPNAME=nvim-vimscript nvim" # my previous nvim config
alias nvchad="NVIM_APPNAME=nvchad nvim"
alias s="kitty +kitten ssh" # automatically copy terminfo files to server: see https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work
alias clear="clear; echo Tsk tsk...use ctrl-l!"
alias du="dust"
alias psql=" psql" # don't append psql commands (which contain sensitive info) to zsh_history
alias gs="git status"

# custom path/env vars
export PATH="$HOME/.local/bin:$PATH"
export TERMINAL="kitty" # rofi uses this var to launch scripts / ssh
export MYACE_AWS_PROFILE="myace"
export AWS_PROFILE="carbonweb"
export AWS_PROFILE="friday"
export AWS_PROFILE="herme"
