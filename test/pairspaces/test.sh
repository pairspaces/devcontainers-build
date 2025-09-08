#!/bin/bash
set -e

source dev-container-features-test-lib

# === Constants ===
BOOTSTRAP_FILE="/opt/pair/bootstrap.txt"
EXPECTED_TOKEN="test-token"
PAIR_CLI="/opt/pair/pair"
SSH_PORT="2222"
SSHD_CONFIG="/etc/ssh/ps_sshd_config"
SUPERVISORD_CONFIG="/etc/supervisor/conf.d/sshd.conf"

# === Binary checks ===
check "pair CLI installed" bash -c "command -v $PAIR_CLI"
check "sshd is installed" bash -c "command -v sshd"
check "supervisord is installed" bash -c "command -v supervisord"

# === Config file checks ===
check "sshd_config exists" bash -c "[ -f $SSHD_CONFIG ]"
check "sshd_ps_config port matches input" bash -c "grep -q '^Port ${SSH_PORT}' $SSHD_CONFIG"
check "sshd_config contains AuthorizedKeysCommand" \
  bash -c "grep -q '^AuthorizedKeysCommand $PAIR_CLI verify %u %k %t' $SSHD_CONFIG"

check "supervisord config exists" bash -c "[ -f $SUPERVISORD_CONFIG ]"

# === Token checks ===
# check "bootstrap.txt exists" bash -c "[ -f $BOOTSTRAP_FILE ]"
# check "bootstrap.txt contains correct token" bash -c "grep -q '^${EXPECTED_TOKEN}$' $BOOTSTRAP_FILE"

echo "👀 Currently listening ports:"
ss -tuln || echo "ss not available"

# === Runtime checks ===
check "supervisord is running" bash -c "pgrep supervisord"
# check "sshd is listening on port $SSH_PORT" bash -c "ss -tuln | grep -q ':$SSH_PORT'"

# === Results ===
reportResults