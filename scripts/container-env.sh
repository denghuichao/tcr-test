#!/usr/bin/env bash

container_env() {
    local key="$1"
    local env_dir

    for env_dir in /run/s6/container_environment /var/run/s6/container_environment; do
        if [ -r "${env_dir}/${key}" ]; then
            cat "${env_dir}/${key}"
            return 0
        fi
    done

    if [ ! -r /proc/1/environ ]; then
        return 0
    fi

    tr '\0' '\n' </proc/1/environ | awk -v key="${key}" '
        index($0, key "=") == 1 {
            sub("^[^=]*=", "")
            print
            exit
        }
    '
}

env_or_container_env() {
    local key="$1"
    local default_value="${2:-}"
    local value

    value="${!key:-}"
    if [ -z "${value}" ]; then
        value="$(container_env "${key}")"
    fi
    if [ -z "${value}" ]; then
        value="${default_value}"
    fi

    printf '%s' "${value}"
}
