#!//usr/bin/env bash

# Install dependencies
echo -----------------------
echo Installing dependencies
echo -----------------------
sudo apt-get update
sudo apt-get install git build-essential apt-transport-https ca-certificates curl software-properties-common
# Install zsh
echo --------------
echo Installing ZSH
echo --------------
sudo apt-get install zsh

# Set dotfiles directory path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# git autocrlf
git config --global core.autocrlf input

# Download submodules
git submodule update --init

# Update nvm
echo ------------
echo Updating nvm
echo ------------
(
  cd "$DIR/nvm"
  git fetch --tags origin
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$DIR/nvm/nvm.sh"

# Install node LTS and npm
echo ---------------------------
echo Installing node LTS and npm
echo ---------------------------
nvm install lts/* --latest-npm

# Install docker and docker-compose
echo ------------------------------------
echo Installing docker and docker-compose
echo ------------------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce
sudo systemctl start docker
sudo systemctl enable docker
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Yarn
echo ---------------
echo Installing Yarn
echo ---------------
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install --no-install-recommends yarn

# Change shell to ZSH
echo ---------------------
echo Changing shell to ZSH
echo ---------------------
chsh -s $(which zsh)

# Upgrade oh-my-zsh
env ZSH=$DIR/oh-my-zsh sh $DIR/oh-my-zsh/tools/upgrade.sh

# Link dotfiles
ln -sfn $DIR $HOME/.dotfiles
ln -sfn $DIR/zshrc $HOME/.zshrc
ln -sfn $DIR/nvm $HOME/.nvm
ln -sfn $DIR/oh-my-zsh $HOME/.oh-my-zsh
ln -sfn $DIR/dracula/dracula.zsh-theme $DIR/oh-my-zsh/themes/dracula.zsh-theme
ln -sfn $DIR/dircolors/dircolors.ansi-dark $HOME/.dircolors