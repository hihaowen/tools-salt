# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH

# color
export PS1='\[\033[01;35m\]\u@\[\033[01;32m\]\H\[\033[01;34m\]:\w \$\[\033[00m\] '
export CLICOLOR=1
export LSCOLORS=Exfxaxdxcxegedabagacad
export GREP_OPTIONS='--color=auto'

# others
export EDITOR='vim'
