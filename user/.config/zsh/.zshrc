ZSH_HOME="$HOME/.config/zsh"

setopt INTERACTIVE_COMMENTS

autoload -Uz promptinit
promptinit

# Completion
zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename "$ZSH_HOME/.zshrc"
autoload -Uz compinit
compinit

# History
HISTFILE="$ZSH_HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

bindkey -e

# Colorization
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias ls='ls --color=auto --group-directories-first'
export LESS='-R --use-color -Dd+r$Du+b'
export MANPAGER='less -R --use-color -Dd+r -Du+b'

# Aliases
alias ll='ls -lh'
alias lal='ls -lah'

# Prompts
PS1="%B%F{magenta}%n%f%b%F{green}@%m%f%B%F{magenta}:%f%b%F{yellow}%~%f"$'\n'"%B%F{magenta}$%f%b "

# Bindkeys

typeset -g -A key

function bindkey_terminfo {
  local terminfo_key_name="${terminfo[$1]}"
  local widget_name="$2"
  if [[ -n "$terminfo_key_name" ]]; then
    bindkey -- "$terminfo_key_name" "$widget_name"
  fi
}

bindkey_terminfo  khome beginning-of-line               # Home
bindkey_terminfo  kend  end-of-line                     # End
bindkey_terminfo  kich1 overwrite-mode                  # Insert
bindkey_terminfo  kbs   backward-delete-char            # Backspace
bindkey_terminfo  kdch1 delete-char                     # Delete
bindkey_terminfo  kcuu1 up-line-or-history              # Up
bindkey_terminfo  kcud1 down-line-or-history            # Down
bindkey_terminfo  kcub1 backward-char                   # Left
bindkey_terminfo  kcuf1 forward-char                    # Right
bindkey_terminfo  kpp   beginning-of-buffer-or-history  # PgUp
bindkey_terminfo  knp   end-of-buffer-or-history        # PgDown
bindkey_terminfo  kLFT5 backward-word                   # Ctrl+Left
bindkey_terminfo  kcbt  reverse-menu-complete           # Shift+Tab

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  autoload -Uz add-zle-hook-widget
  function zle_application_mode_start { echoti smkx }
  function zle_application_mode_stop { echoti rmkx }
  add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
  add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

## Custom widgets
function _make-frameshot { frameshot }

# TODO
function _forward-delete-word {
}

zle -N _make-frameshot

## Bindings for partial console terminal support.
# TODO ISSUE: Left == Ctrl+Left; Right == Ctrl+Right, thus no backward/forward widgets for words
bindkey "^[[1~" beginning-of-line     # Home
bindkey "^[[4~" end-of-line           # End
bindkey "^H"    backward-delete-word  # Ctrl+Backspace
bindkey "^[[[A" _make-frameshot       # Ctrl+F1
