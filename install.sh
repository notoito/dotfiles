#!/bin/bash

printf "password: "
read -s password
echo "$password" | sudo -S echo "OK"
if [ $? != 0 ]; then
  echo "Password failed"
  exit 1
fi

echo "Install dotfiles..."

SCRIPT_DIR=$(cd $(dirname $0); pwd)
DOTFILES_DIR_EXPECT="${HOME}/dotfiles"

function check-os() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
    Linux*)     machine=linux;;
    Darwin*)    machine=mac;;
    CYGWIN*)    machine=cygwin;;
    MINGW*)     machine=mingw;;
    *)          machine="UNKNOWN:${unameOut}"
  esac
  echo ${machine}
}

function ask {
  while true; do
    echo -n "$1 [y/n]: "
    read ANS
    case $ANS in
      [Yy]*)
        return 0
        ;;  
      [Nn]*)
        return 1
        ;;
      *)
        echo "Please enter y or n"
        ;;
    esac
  done
}

function symlink-replace {
  src=$1
  target=$2
  target_dir=$(dirname "${2}")

  echo "Symlink \"${src}\" to \"${target}\"."

  if [ ! -d "${target_dir}" ] ; then
    mkdir -p "${target_dir}"
  fi

  if [ -L "${target}" ] ; then
    if [[ $(readlink "${target}") == "${src}" ]] ; then
      echo "Target \"${target}\" already installed."
      return 0
    fi
  fi

  if [ -e "${target}" ] ; then
    echo "Target \"${target}\" exists."
    if ! ask "Replace this file?"; then
      exit 1
    fi
    rm -i "${target}"
  fi

  ln -s "${src}" "${target}"
}

function symlink-backup {
  src=$1
  target=$2
  backup=$3

  echo "Symlink \"${src}\" to \"${target}\" with backup."

  if [ -L "${target}" ] ; then
    if [[ $(readlink "${target}") == "${src}" ]] ; then
      echo "Target \"${target}\" already installed."
      return 0
    fi
  fi

  if [ -e "${target}" ] ; then
    mv "${target}" "${backup}"
  fi

  ln -s "${src}" "${target}"
}

function symlink-move {
  new_origin=$1
  target=$2

  echo "Symlink move \"${new_origin}\" to \"${target}\"."

  if [ -L "${target}" ] ; then
    if [[ $(readlink "${target}") == "${new_origin}" ]] ; then
      echo "Target \"${target}\" already installed."
      return 0
    fi
  fi

  if [ -e "${target}" ] ; then
    mv "${target}" "${new_origin}"
  fi

  ln -s "${new_origin}" "${target}"
}

# Check phase
cd $SCRIPT_DIR

if [ -e "${HOME}/.zprofile" ] ; then
  source "${HOME}/.zprofile"
fi

if [[ "${DOTFILES_DIR}" ]]; then
  echo "This dotfiles seems to be installed already."
  if ! ask "Continue?"; then
    exit 1
  fi
fi

if [[ "${DOTFILES_DIR_EXPECT}" != "${SCRIPT_DIR}" ]]; then
  echo "Directory incorrect."
  echo "You need to place this dotfiles directory on ${DOTFILES_DIR_EXPECT}"
  exit 1
fi

if [[ $(check-os) != "mac" && $(check-os) != "linux" ]]; then
  echo "This OS is not supported."
  exit 1
fi

echo "Install for $(check-os)"

if [[ $(check-os) == "mac" ]]; then
  defaults write -g ApplePressAndHoldEnabled -bool false
fi

. ${SCRIPT_DIR}/src/install/brew/install.sh
. ${SCRIPT_DIR}/src/install/.zprofile.d/install.sh
. ${SCRIPT_DIR}/src/install/.zshrc.d/install.sh
. ${SCRIPT_DIR}/src/install/vscode/install.sh
. ${SCRIPT_DIR}/src/install/awscli/install.sh
. ${SCRIPT_DIR}/src/install/dnsmasq/install.sh
. ${SCRIPT_DIR}/src/install/.gitconfig/install.sh

#. ${SCRIPT_DIR}/organization_options.sh
#. ${SCRIPT_DIR}/personal_options.sh

echo "Install dotfiles completed."