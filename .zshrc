alias g='git'
alias ll='ls -laG'
alias d='docker'

promptText='%2~ > '
PS1="%{$(tput bold)$(tput setaf 3)%}$promptText%{$(tput sgr0)%}"

