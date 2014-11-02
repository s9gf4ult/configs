#
# This file is based on the configuration written by
# Bruno Bonfils, <asyd@debian-fr.org>
# Written since summer 2001

#
# My functions (don't forget to modify fpath before call compinit !!)
source /etc/profile
fpath=($HOME/.zsh/functions $fpath)

# colors
eval `dircolors $HOME/.zsh/colors`

autoload -U zutil
autoload -U compinit
autoload -U complist

bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '^U' kill-whole-line
bindkey '^K' kill-line
bindkey "\e[H" beginning-of-line        # Home (xorg)
bindkey "\e[1~" beginning-of-line       # Home (console)
bindkey "\e[4~" end-of-line             # End (console)
bindkey "\e[F" end-of-line              # End (xorg)
bindkey "\e[2~" overwrite-mode          # Ins
bindkey "\e[3~" delete-char             # Delete
bindkey '\eOH' beginning-of-line
bindkey '\eOF' end-of-line
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

# Activation
compinit

# Resource files
for file in $HOME/.zsh/rc/*.rc; do
	source $file
done
stty start undef
stty stop undef

export TERM_DARK=false

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
