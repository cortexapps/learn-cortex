#!/usr/bin/env bash

set -e -o pipefail

echo "Checking for homebrew"
which brew > /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Checking for git"
which git > /dev/null || /bin/bash -c "brew install git"

echo "Checking for just"
which just > /dev/null || /bin/bash -c "brew install just"

echo "Checking for ~/git"
if [ ! -d ~/git ]; then
    mkdir -p ~/git
fi

echo "Checking for Cortex CLI"
which cortex > /dev/null || /bin/bash -c "brew tap cortexapps/tap; brew install cortexapps-cli"

if [ ! -d ~/git/learn-cortex/.git ]; then
   cd ~/git
   git clone https://github.com/cortexapps/learn-cortex.git
fi

cd ~/git/learn-cortex

echo "All set!"

echo ""

echo "Run 'cd ~/git/learn-cortex/; just' to see list of recipes that can be run."
