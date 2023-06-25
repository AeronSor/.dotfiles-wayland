#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

alias src='source ~/.bashrc'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias hype='cd ~/.config/hypr/ && ranger'
