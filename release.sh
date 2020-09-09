#!/bin/sh

set -eu

indent() {
  sed -u 's/^/       /'
}

export_env_dir() {
  env_dir=$1
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|JAVA_OPTS)$'}
  if [ -d "$env_dir" ]; then
    for e in $(ls $env_dir); do
      echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      export "$e=$(cat $env_dir/$e)"
      :
    done
  fi
}

BP_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR=$1
CACHE_DIR=$2
OPT_DIR=$BP_DIR/../opt/

export_env_dir $3

APT_CACHE_DIR="$CACHE_DIR/apt/cache"
APT_STATE_DIR="$CACHE_DIR/apt/state"
APT_OPTIONS="-o debug::nolocking=true -o dir::cache=$APT_CACHE_DIR -o dir::state=$APT_STATE_DIR"

mkdir -p "$APT_CACHE_DIR/archives/partial"
mkdir -p "$APT_STATE_DIR/lists/partial"

echo "-----> Installing... "
apt-get $APT_OPTIONS update -y | indent
apt-get $APT_OPTIONS -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -d install --reinstall gdebi-core | indent

wget -O ~/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
gdebi ~/discord.deb -y