#!/bin/bash
echo ------------------------------
echo Set environment variables
echo ------------------------------
export ACCEPT_EULA=Y
export DEBIAN_FRONTEND=noninteractive
export PYTHON_VERSION=3.13
export PREVIOUS_PYTHON_VERSION=3.12
export ROOT_DIR=$(pwd)
export XDG_CONFIG_HOME=$ROOT_DIR/.config
export XDG_DATA_HOME=$ROOT_DIR/.local/share
export UV_PYTHON_INSTALL_DIR=$XDG_DATA_HOME/uv/python
export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which javac))))"
export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
echo ------------------------------
echo Initializing environment variables
echo ------------------------------
echo "export XDG_CONFIG_HOME=${XDG_CONFIG_HOME}" >> ~/.zshrc
echo "export XDG_STATE_HOME=${XDG_STATE_HOME}" >> ~/.zshrc
echo "export XDG_DATA_HOME=${XDG_DATA_HOME}" >> ~/.zshrc
echo "export JAVA_HOME=${JAVA_HOME}" >> ~/.zshrc
echo "export NODE_OPTIONS='--max-old-space-size=8192'" >> ~/.zshrc
echo "export UV_PYTHON_INSTALL_DIR=${UV_PYTHON_INSTALL_DIR}" >> ~/.zshrc
echo "export NVM_DIR=${NVM_DIR}" >> ~/.zshrc
echo ------------------------------
echo Create default working directories
echo ------------------------------
mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME
mkdir -p $NVM_DIR
echo ------------------------------
echo Install system packages
echo ------------------------------
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source $NVM_DIR/nvm.sh && nvm install --lts
export NODE_EXECUTABLE="$(which node)"
echo "export NODE_EXECUTABLE=${NODE_EXECUTABLE}" >> ~/.profile
echo ------------------------------
echo Install standalone python versions
echo ------------------------------
uv self update
uv python install ${PYTHON_VERSION} ${PREVIOUS_PYTHON_VERSION}
echo ------------------------------
echo Install ai helpers
echo ------------------------------
npm install -g @google/gemini-cli
gh extension install github/gh-copilot
gh extension upgrade gh-copilot
echo 'eval "$(gh copilot alias -- bash)"' >> ~/.bashrc
echo 'eval "$(gh copilot alias -- zsh)"' >> ~/.zshrc
echo ------------------------------
