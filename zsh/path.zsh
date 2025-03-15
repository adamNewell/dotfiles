eval "$(/opt/homebrew/bin/brew shellenv)"
PATH=$PATH:$(brew --prefix coreutils)/libexec/gnubin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:$HOME/go/bin
PATH=$PATH:$HOME/.cargo/bin
PATH=$PATH:/opt/homebrew/opt/e2fsprogs/bin
PATH=$PATH:/opt/homebrew/opt/e2fsprogs/sbin
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
