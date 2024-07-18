#!/usr/bin/env bash

# This script largely lifted from https://github.com/andrew8088/dotfiles/blob/main/install/bootstrap.sh

cd "$(dirname "$0")/.."
export DOTFILES=$(pwd -P)
export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=$HOME/.cache

mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_CACHE_HOME

git submodule init
git submodule update

set -e

echo ''

# Source the shared output functions
source "$(dirname "$0")/output_functions.sh"

link_file () {
  local src=$1 dst=$2

  local overwrite=
  local backup=
  local skip=
  local action=

  if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      # ignoring exit 1 from readlink in case where file already exists
      # shellcheck disable=SC2155
      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action  < /dev/tty

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

create_env_file () {
    if test -f "$XDG_CONFIG_HOME/.env"; then
        success "$XDG_CONFIG_HOME/.env file already exists, skipping"
    else
        echo "export DOTFILES=$DOTFILES" > $XDG_CONFIG_HOME/.env
        success 'created .env file'
    fi
}

install_deps () {
    info 'Running deps.sh scripts'
    find "$DOTFILES" -mindepth 2 -maxdepth 2 -name 'deps.sh' -type f | while read install_script
    do
        info "Running $install_script"
        if bash "$install_script"; then
            success "Completed $install_script"
        else
            fail "Failed to run $install_script"
        fi
    done
}

install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  eval "$(/opt/homebrew/bin/brew shellenv)"
  
  find -H "$DOTFILES" -maxdepth 2 -name 'links.prop' -not -path '*.git*' | while read -r linkfile
  do
    while IFS= read -r line
    do
        # Skip empty lines and lines starting with #
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        local src dst dir
        src=$(echo "$line" | cut -d '=' -f 1)
        dst=$(echo "$line" | cut -d '=' -f 2)
        src=$(eval echo "$src")
        dst=$(eval echo "$dst")
        dir=$(dirname "$dst")
        mkdir -p "$dir"
        link_file "$src" "$dst"
    done < "$linkfile"
  done
}

create_env_file
install_deps
install_dotfiles

echo ''
echo 'Setting reasonable MacOS defaults...'
source ./install/macos.sh

yabai --start-service
skhd --start-service

success 'All installed!'

# Delete remaining artifacts of pre-configured machine
rm ~/.viminfo
rm ~/.zsh_history

info 'You will need to restart your machine for all changes to take effect'
