#!/usr/bin/env bash
set -euo pipefail

if [ "${START_DOCKERD:-1}" = "1" ]; then
    start-dockerd
fi

exec "$@"
