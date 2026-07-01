#!/usr/bin/env bash
set -euo pipefail

DOCKERD_LOG_FILE="${DOCKERD_LOG_FILE:-/tmp/dockerd.log}"
DOCKERD_STORAGE_DRIVER="${DOCKERD_STORAGE_DRIVER:-vfs}"

start_dockerd() {
    if docker info >/dev/null 2>&1; then
        echo "Docker daemon is already available."
        return 0
    fi

    if [ -S /var/run/docker.sock ]; then
        echo "Docker socket exists, but the daemon is not responding." >&2
        echo "Set START_DOCKERD=0 if you want to use a mounted host Docker socket." >&2
        return 1
    fi

    mkdir -p /var/lib/docker /var/run
    rm -f /var/run/docker.pid

    echo "Starting Docker daemon with ${DOCKERD_STORAGE_DRIVER} storage driver..."
    dockerd \
        --host=unix:///var/run/docker.sock \
        --storage-driver="${DOCKERD_STORAGE_DRIVER}" \
        >"${DOCKERD_LOG_FILE}" 2>&1 &

    local dockerd_pid="$!"
    local i
    for i in $(seq 1 60); do
        if docker info >/dev/null 2>&1; then
            echo "Docker daemon is ready."
            return 0
        fi

        if ! kill -0 "${dockerd_pid}" >/dev/null 2>&1; then
            echo "Docker daemon exited before becoming ready." >&2
            cat "${DOCKERD_LOG_FILE}" >&2
            return 1
        fi

        sleep 1
    done

    echo "Timed out waiting for Docker daemon." >&2
    cat "${DOCKERD_LOG_FILE}" >&2
    return 1
}

if [ "${START_DOCKERD:-1}" = "1" ]; then
    start_dockerd
fi

exec "$@"
