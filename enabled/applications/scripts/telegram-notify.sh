#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p bash curl sops coreutils
#
# telegram-notify.sh — Send a Telegram message with fleet notification credentials.
#
# Usage:
#   telegram-notify.sh MESSAGE...
#   some-command | telegram-notify.sh -        # read the message from stdin
#
# Message arguments are joined with spaces, so embedded newlines are preserved.
#
# Credentials are TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID. They may be present
# in the environment already, or come from a SOPS YAML file under a
# `fleet-notify` key, as a multi-line string:
#   fleet-notify: |
#     TELEGRAM_BOT_TOKEN=123456:ABC...
#     TELEGRAM_CHAT_ID=123456789
#
# Lookup order:
#   1. The environment, when both variables are already set
#   2. FLEET_NOTIFY_SOPS: path to the *encrypted* YAML file, decrypted here
#      with the sops CLI (needs your age/ssh key available to sops)
#   3. FLEET_NOTIFY_ENV: path to an already-decrypted file
#      (default: /run/secrets/fleet-notify, as placed by sops-nix)
#
# The secret content is parsed as text, never executed, and both `KEY=value`
# and YAML-style `KEY: value` lines are accepted.
#
# Exit status: 0 on success or when notifications are simply unconfigured,
# 1 when a configured send failed, 2 on usage errors.

set -Eeuo pipefail

usage() {
    cat <<'EOF'
Usage: telegram-notify.sh MESSAGE...
       some-command | telegram-notify.sh -

Send MESSAGE to the Telegram chat configured via TELEGRAM_BOT_TOKEN and
TELEGRAM_CHAT_ID. With `-`, the message is read from stdin instead.

Credentials are taken from the environment when both variables are set;
otherwise they are loaded from FLEET_NOTIFY_SOPS (an encrypted SOPS YAML
file) or FLEET_NOTIFY_ENV (default: /run/secrets/fleet-notify).

MESSAGE arguments are joined with spaces; newlines inside them are kept.
EOF
}

parse_notify_secrets() {
    local line key val
    while IFS= read -r line || [ -n "$line" ]; do
        line=${line%$'\r'}
        if [[ $line =~ ^[[:space:]]*(TELEGRAM_BOT_TOKEN|TELEGRAM_CHAT_ID)[[:space:]]*[:=][[:space:]]*(.*)$ ]]; then
            key=${BASH_REMATCH[1]}
            val=${BASH_REMATCH[2]}
            val=${val%"${val##*[![:space:]]}"}   # trim trailing whitespace
            val=${val#[\"\']}                    # strip optional quotes
            val=${val%[\"\']}
            printf -v "$key" '%s' "$val"
            export "${key?}"
        fi
    done <<< "$1"
}

load_notify_secrets() {
    if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
        return 0
    fi

    local content=""
    if [ -n "${FLEET_NOTIFY_SOPS:-}" ]; then
        if ! content=$(sops -d --extract '["fleet-notify"]' "$FLEET_NOTIFY_SOPS" 2>/dev/null \
                       || sops -d "$FLEET_NOTIFY_SOPS" 2>/dev/null); then
            echo "telegram-notify: sops decrypt of $FLEET_NOTIFY_SOPS failed" >&2
        fi
    else
        local env_file="${FLEET_NOTIFY_ENV:-/run/secrets/fleet-notify}"
        if [ -r "$env_file" ]; then
            content=$(cat "$env_file") || true
        fi
    fi
    parse_notify_secrets "$content"
}

if [ "$#" -eq 0 ]; then
    echo "telegram-notify: no message given" >&2
    usage >&2
    exit 2
fi

msg=""
case "$1" in
    -h|--help)
        usage
        exit 0
        ;;
    -)
        shift
        if [ "$#" -gt 0 ]; then
            echo "telegram-notify: '-' reads stdin and takes no extra arguments" >&2
            exit 2
        fi
        msg=$(cat)
        ;;
    *)
        msg="$*"
        ;;
esac

load_notify_secrets

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
    echo "telegram-notify: not configured, skipping message" >&2
    exit 0
fi

# Telegram caps messages at 4096 chars; trim well below that
if ! curl -fsS --max-time 15 \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
        --data-urlencode "text=${msg:0:4000}" \
        >/dev/null; then
    echo "telegram-notify: send failed" >&2
    exit 1
fi
