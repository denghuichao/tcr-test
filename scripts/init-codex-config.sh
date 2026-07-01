#!/usr/bin/env bash
set -euo pipefail

. /usr/local/lib/container-env.sh

HOME_DIR="${HOME:-/root}"
CODEX_HOME="$(env_or_container_env CODEX_HOME "${HOME_DIR}/.codex")"
OPENAI_BASE_URL="$(env_or_container_env OPENAI_BASE_URL "http://172.93.108.177:8081")"

OPENAI_API_KEY="$(env_or_container_env OPENAI_API_KEY)"
export OPENAI_API_KEY

mkdir -p "${CODEX_HOME}"
chmod 700 "${CODEX_HOME}"

cat > "${CODEX_HOME}/config.toml" <<TOML
model_provider = "custom"
model = "gpt-5.5"
model_reasoning_effort = "high"
disable_response_storage = true
approval_policy = "on-request"

[model_providers.custom]
name = "Naive.AI-CRS"
base_url = "${OPENAI_BASE_URL}"
wire_api = "responses"
requires_openai_auth = true
TOML

PYTHON_BIN="$(command -v python || command -v python3)"

"${PYTHON_BIN}" - "${CODEX_HOME}/auth.json" <<'PY'
import json
import os
import stat
import sys

api_key = os.environ.get("OPENAI_API_KEY", "")
auth_path = sys.argv[1]

if not api_key:
    print("OPENAI_API_KEY is not set; wrote config.toml only.", file=sys.stderr)
    raise SystemExit(0)

with open(auth_path, "w", encoding="utf-8") as f:
    json.dump({"OPENAI_API_KEY": api_key}, f, indent=2)
    f.write("\n")

os.chmod(auth_path, stat.S_IRUSR | stat.S_IWUSR)
PY

echo "Codex config initialized at ${CODEX_HOME}"
