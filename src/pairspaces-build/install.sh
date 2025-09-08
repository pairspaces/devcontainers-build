#!/bin/bash
set -e

detect_arch() {
  if command -v dpkg >/dev/null 2>&1; then
    case "$(dpkg --print-architecture)" in
      amd64|arm64) echo "$(dpkg --print-architecture)"; return 0 ;;
      *) echo "Unsupported dpkg arch: $(dpkg --print-architecture)" >&2; return 1 ;;
    esac
  fi

  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      return 1
      ;;
  esac
}

ARCH="$(detect_arch)"
PAIR_VERSION="2.7.0-build.3"
PAIR_CLI_URL="https://github.com/pairspaces/install/releases/download/v${PAIR_VERSION}/pair_${PAIR_VERSION}_linux_${ARCH}"
PAIR_CLI_PATH="/opt/pair/pair"
PORT="${VAR_PORT:-2222}"
SSHD_CONFIG_TEMPLATE="files/sshd_config.template"
SSHD_CONFIG_TARGET="/etc/ssh/ps_sshd_config"
SUPERVISOR_CONF_DIR="/etc/supervisor/conf.d"
SUPERVISORD_MAIN_CONF="/etc/supervisor/supervisord.conf"
TOKEN="${TOKEN:-CHANGED_ME}"


install_packages() {
  local retries=3
  until apt-get update; do
    ((retries--))
    [[ $retries -le 0 ]] && echo "apt-get update failed after retries" && exit 1
    echo "Retrying apt-get update..."
    sleep 3
  done

  retries=3
  until DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server curl ca-certificates sudo gnupg iproute2 libkmod2 supervisor; do
    ((retries--))
    [[ $retries -le 0 ]] && echo "apt-get install failed after retries" && exit 1
    echo "Retrying apt-get install..."
    apt-get update --fix-missing
    sleep 3
  done
}

install_pair_cli() {
  mkdir -p "$(dirname "$PAIR_CLI_PATH")"
  curl -fsSL "$PAIR_CLI_URL" -o "$PAIR_CLI_PATH"
  chmod +x "$PAIR_CLI_PATH"
}

configure_sshd() {
  mkdir -p /var/run/sshd /etc/ssh

  if [[ -f "$SSHD_CONFIG_TEMPLATE" ]]; then
    sed "s/__PORT__/${PORT}/g" "$SSHD_CONFIG_TEMPLATE" > "$SSHD_CONFIG_TARGET"
  else
    echo "No sshd config found"
    exit 1
  fi

  ssh-keygen -A
}

configure_supervisord() {
  mkdir -p "$SUPERVISOR_CONF_DIR"

  cat <<EOF > "${SUPERVISOR_CONF_DIR}/sshd.conf"
[program:sshd]
command=/usr/sbin/sshd -D -e -f $SSHD_CONFIG_TARGET
autostart=true
autorestart=true
stderr_logfile=/var/log/sshd.err.log
stdout_logfile=/var/log/sshd.out.log
EOF

  cat <<EOF > "$SUPERVISORD_MAIN_CONF"
[supervisord]
nodaemon=false
user=root
logfile=/var/log/supervisord.log
pidfile=/var/run/supervisord.pid

[include]
files = $SUPERVISOR_CONF_DIR/*.conf
EOF
}

write_token() {
  if [[ -z "$TOKEN" ]]; then
    echo "TOKEN is not set. This feature requires a token."
    exit 1
  fi

  mkdir -p "$(dirname "$PAIR_CLI_PATH")"
  echo "$TOKEN" > "/opt/pair/bootstrap.txt"
}

main() {
  install_packages
  install_pair_cli
  configure_sshd
  configure_supervisord
  write_token
}

main "$@"