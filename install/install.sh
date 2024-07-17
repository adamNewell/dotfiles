#!/bin/bash
# Generally speaking, this script will get converted into a gist and put behind a bit.ly link for use

# Check if Xcode Command Line Tools are already installed
if xcode-select -p &> /dev/null; then
    echo "Xcode Command Line Tools are already installed."
else
    echo "Xcode Command Line Tools not found. Installing..."
    
    # Trigger the installation
    xcode-select --install &> /dev/null
    
    # Wait for the installation to complete
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    
    echo "Xcode Command Line Tools have been installed."
fi

# Accept the license agreement
sudo xcodebuild -license accept

echo "Installation and license agreement completed."

git clone https://github.com/adamNewell/dotfiles.git $HOME/.dotfiles

function config {
   git --git-dir=$HOME/.dotfiles/
}

config checkout
if [ $? = 0 ]; then
  echo "Checked out config."
  cd 
  else
    echo "Backing up pre-existing dot files."
    mkdir -p .dotfiles.backup
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles.backup/{}
fi;

cd .dotfiles
./install/bootstrap.sh