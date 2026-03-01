#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ] || [ -z "${EPHEMERAL_SSH_AGENT_KEYS:-}" ]; then
	    cat >&2 <<EOF
Usage: EPHEMERAL_SSH_AGENT_KEYS=<key>[,<key>...] ephemeral-ssh-agent [ssh options] [user@]host

Environment variables:
    EPHEMERAL_SSH_AGENT_KEYS    Comma-separated paths to private keys (required)
EOF
    exit 1
fi

keys="${EPHEMERAL_SSH_AGENT_KEYS//,/ }"

set -x
exec ssh-agent bash -c "ssh-add $keys && exec ssh \"\$@\"" _ "$@"
