#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

alias ba='nvim ~/.bashrc'
alias src='source ~/.bashrc'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias dot='cd ~/.dotfiles-wayland/ && ranger'
alias nvm='cd ~/.dotfiles-wayland/AeroNvim/.config/nvim/ && ranger'
alias hype='cd ~/.config/hypr/ && ranger'
alias elko='cd ~/.config/eww/ && ranger'
