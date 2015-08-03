#!/usr/bin/env bash

_get_brew() {
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
}

_get_proper_python() {
  brew tap homebrew/dupes;
  brew install python --universal --with-poll --with-tcl-tk;
  brew link --overwrite python;
}

_get_proper_git() {
  brew install git \
    --with-blk-sha1 \
    --with-brewed-curl \
    --with-brewed-openssl \
    --with-gettext \
    --with-pcre \
    --with-persistent-https;
  brew link git;
}

_get_proper_bash() {
  brew install bash;
  local BREW_BASH_PATH='/usr/local/bin/bash';
  if ! grep -Fxq "$BREW_BASH_PATH" /etc/shells; then
    echo "$BREW_BASH_PATH" | sudo tee -a /etc/shells;
    chsh -s "$BREW_BASH_PATH";
  fi
}


_get_proper_curl() {
  brew install curl \
    --with-c-ares \
    --with-gssapi \
    --with-libidn \
    --with-libmetalink \
    --with-libssh2 \
    --with-nghttp2 \
    --with-openssl \
  ;
  brew link --force curl;
}

_get_proper_openssl() {
  brew install openssl --universal;
}

init_mac() {
  local INVENTORY_FILE='mac';
  local PLAYBOOK='mac.yml';

  local ANSIBLE_INSTALL_SCRIPT_VERSION='develop';
  local ANSIBLE_INSTALL_SCRIPT="https://raw.githubusercontent.com/shrikeh/ansible-virtualenv/$ANSIBLE_INSTALL_SCRIPT_VERSION/init.sh";
  local TMP_FOLDER=$(mktemp -d -t 'mac-init');
  local INSTALL_ANSIBLE_SCRIPT="$TMP_FOLDER/init.sh";
  local ANSIBLE_REPOSITORY_URL='';
  local ANSIBLE_ROLES_FILE='./ansible-roles.yml';

  local VAULT_PASSWORD_FILE='/Volumes/UNTITLED/vault.txt';

  _get_brew;
  _get_proper_openssl;
  _get_proper_bash;
  _get_proper_curl;
  _get_proper_git;
  _get_proper_python;

  export PATH=/usr/local/bin:$PATH;

  export ANSIBLE_ROLES_PATH='./.galaxy';

  local TMP_VAULT_PASSWORD_FILE=$(mktemp -t 'vault_password');

  cp "$VAULT_PASSWORD_FILE" "$TMP_VAULT_PASSWORD_FILE";

  chmod ugo-x "$TMP_VAULT_PASSWORD_FILE";

  rm -f "$INSTALL_ANSIBLE_SCRIPT"; # delete existing if it is already there
  curl -L --silent "$ANSIBLE_INSTALL_SCRIPT" > "$INSTALL_ANSIBLE_SCRIPT";
  . "$INSTALL_ANSIBLE_SCRIPT" --use-pip-version;

  ansible-galaxy install -r "$ANSIBLE_ROLES_FILE";
  ansible-playbook \
  -i "$INVENTORY_FILE" "$PLAYBOOK" \
  --ask-become-pass \
  --vault-password-file="$TMP_VAULT_PASSWORD_FILE" \
  --tags=ssh;
}

init_mac;
