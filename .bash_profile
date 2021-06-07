# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

if [ -d "$HOME/bin" ]
then
	PATH="$HOME/bin:$PATH:."
else
	PATH="$PATH:."
fi

BASH_ENV=$HOME/.bashrc
USERNAME=""

export USERNAME BASH_ENV PATH

