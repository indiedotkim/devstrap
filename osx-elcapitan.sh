#!/usr/bin/env bash

MANUAL_INST=devstrap

RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
BLUE=$'\e[1;34m'
MAGENTA=$'\e[1;35m'
CYAN=$'\e[1;36m'
NOCOLOR=$'\e[0m'

function c {
  printf "${CYAN}Configuring: ${GREEN}%s${NOCOLOR}\n" "$1"
}

function dl {
  printf "${CYAN}Downloading: ${GREEN}%s${NOCOLOR}\n" "$1"
}

function i {
  printf "${CYAN}Installing:  ${GREEN}%s${NOCOLOR}\n" "$1"
}

function imp {
  printf "${RED}%s${NOCOLOR}\n" "$1"
}

function inf {
  printf "${CYAN}Downloaded files on the desktop in: ${MANUAL_INST}${NOCOLOR}\n"
}

function sec {
  printf "${YELLOW}\n--- %s ---${NOCOLOR}\n\n" "$1"
}

set -e

sec "Initialization"

cd ~/Desktop

if [ -d "$MANUAL_INST" ] ; then
  exit 1
fi

mkdir "$MANUAL_INST" && cd "$MANUAL_INST"

# vim user config

if [ -f "~/.vimrc" ] ; then
  mv ~/.vimrc ~/.vimrc-bak
fi

echo -e "syntax on\ncolorscheme peachpuff\nfiletype plugin indent on\nset tabstop=4\nset shiftwidth=4\nset expandtab" > ~/.vimrc

#
# Downloads -- things for the user to install manually
#

sec "Manual Installers and Themes"

# Docker Toolbox

dl "Docker Toolbox" && curl -L -O https://github.com/docker/toolbox/releases/download/v1.8.3/DockerToolbox-1.8.3.pkg

# Firefox

dl "Firefox" && curl -L "https://download.mozilla.org/?product=firefox-41.0.2-SSL&os=osx&lang=en-US" -o "Firefox 41.0.2-SSL.dmg"

# iTerm2

dl "iTerm2" && curl -L -O https://iterm2.com/downloads/stable/iTerm2-2_1_4.zip

dl "iTerm2 Color Schemes" && curl -L https://github.com/mbadolato/iTerm2-Color-Schemes/zipball/master -o "iTerm2 Color Schemes.zip"
cd ..

#
# Installs -- things that are deployed automagically
#

sec "Development Tools and Frameworks"

# Homebrew

i "Homebrew" && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update

# Python for development

i "Python" && brew install python

# C/C++ related tools

i "Automake" && brew install automake
i "CMake" && brew install cmake

# Databases

i "MongoDB" && brew install mongodb --with-openssl
i "PostgresQL" && brew install postgresql
i "RethinkDB" && brew install rethinkdb

# Data Analysis/Processing

i "Hadoop" && brew install hadoop

# Web-development

i "Node" && brew install node
i "Django" && pip install Django==1.8.5
imp "Password needed (sudo gem...)!"
i "Jekyll" && sudo gem install jekyll
i "Jekyll Paginate" && sudo gem install jekyll-paginate
i "Redcarpet" && sudo gem install redcarpet
i "Pygments (Python)" && pip install Pygments
i "Pygments (Ruby)" && sudo gem install pygments.rb
i "Meteor" && curl https://install.meteor.com/ | sh

# Go

mkdir -p ~/.go/bin
grep 'GOPATH' ~/.zshrc || echo -e "\nexport GOPATH=$HOME/.go\nexport PATH=$PATH:$HOME/.go/bin\nexport GO15VENDOREXPERIMENT=1" >> ~/.zshrc

# Hadoop

if [[ "$HADOOP_PREFIX" != "" ] ; then
  imp "Hadoop already configured!"
else
  HADOOP_PREFIX=`find /usr/local/Cellar/hadoop/*/libexec/bin -name hdfs | sed -E 's/\/bin.*$//'`

  cat <<EOF > "$HADOOP_PREFIX"/etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF
  cat <<EOF > "$HADOOP_PREFIX"/etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
EOF

  echo -e "\nexport HADOOP_PREFIX=$HADOOP_PREFIX" >> ~/.zshrc
  echo -e "\nexport PATH=$PATH:/usr/local/sbin" >> ~/.zshrc
fi

# zsh

imp "!!!"
imp "!!! EXIT ZSH TO CONTINUE WITH DEVSTRAP (PRESS CTRL-D)"
imp "!!!"
i "Oh My Zsh" && sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

i "Powerline" && pip install powerline-status

cd ~/.oh-my-zsh/custom
i "Powerlevel9k zsh-theme" && git clone https://github.com/bhilburn/powerlevel9k.git themes/powerlevel9k
cp ~/.zshrc ~/.zshrc-bak
<~/.zshrc-bak sed -E 's/ZSH_THEME/ZSH_THEME="powerlevel9k\/powerlevel9k"\'$'\n''# ZSH_THEME/' > ~/.zshrc

cd ~/Desktop/$MANUAL_INST
git clone https://github.com/powerline/fonts.git powerline-fonts
cd powerline-fonts
./install.sh

imp ""
imp "--- FINAL MANUAL INSTALLATION STEPS ---"
imp ""
imp "iTerm2 color themes are located in the ZIP archive in the 'schemes' directory."
imp "In iTerm2, go to 'Edit Profiles', 'Colors', 'Load Presets...', then select"
imp "all files in the 'schemes' directory to import all color presets at once."
imp ""
imp "Hadoop requires that an SSH server is up and running."
imp "Click 'System Preferences', then 'Sharing', and turn 'On' the 'Remote Login' service."
imp ""
inf

