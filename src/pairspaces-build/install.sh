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
PAIR_VERSION="2.9.0-build.21"
PAIR_CLI_URL="https://github.com/pairspaces/install/releases/download/v${PAIR_VERSION}/pair_${PAIR_VERSION}_linux_${ARCH}"
PAIR_CLI_PATH="/opt/pair/pair"


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
    openssh-server curl ca-certificates sudo gnupg iproute2 libkmod2; do
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
  ssh-keygen -A
}

main() {
  install_packages
  install_pair_cli
  configure_sshd
}

main "$@"
