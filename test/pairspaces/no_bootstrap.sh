#!/bin/bash
set -e

source dev-container-features-test-lib

# === Constants ===
BOOTSTRAP_FILE="/opt/pair/bootstrap.txt"
SPACE_KEY_FILE="/etc/profile.d/pair.sh"
PAIR_CLI="/opt/pair/pair"

# === Binary checks ===
check "pair CLI installed" bash -c "command -v $PAIR_CLI"
check "sshd is installed" bash -c "command -v sshd"

# === SSHD setup checks ===
check "sshd host keys exist" bash -c "find /etc/ssh -name 'ssh_host_*_key' -type f | grep -q ."
check "feature does not create PairSpaces sshd config" bash -c "[ ! -f /etc/pairspaces/sshd_config ]"

# === Secret material checks ===
check "bootstrap.txt is not created" bash -c "[ ! -f $BOOTSTRAP_FILE ]"
check "PS_SPACE_KEY profile file is not created by feature install" bash -c "[ ! -f $SPACE_KEY_FILE ]"

echo "👀 Currently listening ports:"
ss -tuln || echo "ss not available"

# === Results ===
reportResults
