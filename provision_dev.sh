#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

provision_backport=1

if [[ $1 = "--skip-backport" ]]; then
  provision_backport=0
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -q
apt-get install -q -y curl exuberant-ctags git-core ruby tmux vim wget

if [[ $(uname -m) =~ 64 ]]; then
  if [[ $provision_backport = 1 ]]; then
    tmp=`mktemp -q` && {
      apt-get install -q -y --no-upgrade linux-image-generic-lts-raring | tee "$tmp"
      NUM_INST_PACKAGES=`awk '$2 == "upgraded," && $4 == "newly" { print $3 }' "$tmp"`
      rm "$tmp"
    }

    if [[ $NUM_INST_PACKAGES -gt 0 ]]; then
      echo -e "\n***************************************************"
      echo -e "Rebooting to activate new kernel.\n"
      echo    "Use \`vagrant up --provision\` to complete the build."
      echo -e "***************************************************\n"
      shutdown -h now
      exit 0
    fi
  fi

  if [[ -z $(type -p docker) ]]; then
    wget -q -O - https://get.docker.io/gpg | apt-key add -
    echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
    apt-get update -q
    apt-get install -q -y --force-yes lxc-docker
  fi

  dockerize_version="master"
  dockerize_source="https://github.com/roovo/dockerize/archive/${dockerize_version}"
  dockerize_download_Location="/usr/local/src/dockerize-${dockerize_version}"
  dockerize_dir="/usr/local/src/dockerize"
  dockerize_bin="${dockerize_dir}/bin/dockerize"

  if [[ ! -e $dockerize_bin ]]; then
    [[ -d $dockerize_dir ]] && rm -f "${dockerize_dir}"
    wget -q -O - "${dockerize_source}.tar.gz" | tar -C /usr/local/src -zxv
    mv "${dockerize_download_Location}" "${dockerize_dir}"
  fi
else
  echo "Unable to install docker as this is not a 64-bit system" 1>&2
fi

echo -e "\nVM ready - on first log in:"
echo    "  * add yourself to the docker group \`sudo usermod -a -G docker <user>\`"
echo    "  * set up dotfiles \`bash <(curl -sSL https://raw.github.com/roovo/dotfiles/master/scripts/bootstrap)\`"
echo -e "  * and log out and in again to pick up the new permissions and dotfile stuff\n"
