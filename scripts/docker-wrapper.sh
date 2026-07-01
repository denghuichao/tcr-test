#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-/usr/bin/docker}"

case "${1:-}" in
    -v|--version|version|help|--help|-h)
        exec "${DOCKER_BIN}" "$@"
        ;;
esac

if [ "${START_DOCKERD:-1}" = "1" ]; then
    start-dockerd
fi

exec "${DOCKER_BIN}" "$@"
