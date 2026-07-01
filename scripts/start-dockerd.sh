#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-/usr/bin/docker}"
DOCKERD_LOG_FILE="${DOCKERD_LOG_FILE:-/tmp/dockerd.log}"
DOCKERD_STORAGE_DRIVER="${DOCKERD_STORAGE_DRIVER:-vfs}"

if "${DOCKER_BIN}" info >/dev/null 2>&1; then
    echo "Docker daemon is already available."
    exit 0
fi

if [ -S /var/run/docker.sock ]; then
    echo "Docker socket exists, but the daemon is not responding." >&2
    echo "Set START_DOCKERD=0 if you want to use a mounted host Docker socket." >&2
    exit 1
fi

mkdir -p /var/lib/docker /var/run
rm -f /var/run/docker.pid

echo "Starting Docker daemon with ${DOCKERD_STORAGE_DRIVER} storage driver..."
dockerd \
    --host=unix:///var/run/docker.sock \
    --storage-driver="${DOCKERD_STORAGE_DRIVER}" \
    >"${DOCKERD_LOG_FILE}" 2>&1 &

dockerd_pid="$!"
for _ in $(seq 1 60); do
    if "${DOCKER_BIN}" info >/dev/null 2>&1; then
        echo "Docker daemon is ready."
        exit 0
    fi

    if ! kill -0 "${dockerd_pid}" >/dev/null 2>&1; then
        echo "Docker daemon exited before becoming ready." >&2
        cat "${DOCKERD_LOG_FILE}" >&2
        exit 1
    fi

    sleep 1
done

echo "Timed out waiting for Docker daemon." >&2
cat "${DOCKERD_LOG_FILE}" >&2
exit 1
