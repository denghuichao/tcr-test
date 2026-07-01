# Python Base Development Image

Sandbox-compatible Linux + Python development image for Tencent Cloud Container Registry.

Image:

```bash
conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

## What's Included

- Base image: `ccr.ccs.tencentyun.com/ags-image/sandbox-code:latest`
- Keeps the sandbox / E2B-compatible data plane capabilities from the base image
- Debian bookworm Linux base
- Python 3.12
- pip, uv, virtualenv, aiohttp
- Codex CLI: `@openai/codex@latest`
- Docker Engine, Docker CLI, docker buildx, docker compose plugin
- git, curl, wget, openssh-client
- build-essential, gcc, g++, make
- pytest, pytest-cov, ruff, black, mypy, ipython, debugpy
- vim, nano, jq, htop, tree, unzip, zip, sudo

Note: this image extends Tencent Cloud's `sandbox-code` base image, so it is a better fit for sandbox / code-interpreter style platforms than a plain Debian or Python image.

Note: this image keeps the base image entrypoint, so the sandbox / E2B-compatible data plane can still start normally. The default command starts an internal Docker daemon before opening the shell.

## Login

Use the login command from Tencent Cloud Container Registry. Prefer `--password-stdin` when entering credentials manually:

```bash
printf '%s' 'YOUR_PASSWORD_OR_ACCESS_TOKEN' | docker login conductor-artifacts.tencentcloudcr.com \
  --username YOUR_USERNAME \
  --password-stdin
```

For the temporary credential shown in Tencent Cloud console, you can also run the copied command directly:

```bash
docker login conductor-artifacts.tencentcloudcr.com --username YOUR_USERNAME --password YOUR_PASSWORD_OR_ACCESS_TOKEN
```

## Build

Build for the current machine architecture:

```bash
docker buildx build \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest \
  .
```

If your platform requires pushing at build time, use:

```bash
docker buildx build \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest \
  --push \
  .
```

Build for Apple Silicon / ARM64:

```bash
docker buildx build --platform linux/arm64 \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest \
  .
```

Build for common x86 Linux servers:

```bash
docker buildx build --platform linux/amd64 \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest \
  .
```

Build and push a multi-architecture image for both x86 Linux servers and Apple Silicon:

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest \
  --push \
  .
```

## Run

Run an interactive shell:

```bash
docker run --privileged -it --rm \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

This image defaults to:

```bash
bash
```

On startup, the default command starts `dockerd` and waits until `docker info` succeeds. The image does not override the base image entrypoint.

Run with the current project mounted to `/workspace`:

```bash
docker run --privileged -it --rm \
  -v "$PWD":/workspace \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

Run with a persistent Docker data directory:

```bash
docker run --privileged -it --rm \
  -v "$PWD":/workspace \
  -v swe-docker-lib:/var/lib/docker \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

After entering the container, verify tools:

```bash
python --version
pip --version
uv --version
docker --version
docker info
docker buildx version
docker compose version
codex --version
```

The daemon uses the `vfs` storage driver by default because it is usually the most compatible inside sandboxed containers. If your platform supports overlay filesystems, you can use the faster `overlay2` driver:

```bash
docker run --privileged -it --rm \
  -e DOCKERD_STORAGE_DRIVER=overlay2 \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

To disable the internal daemon and use an externally mounted Docker socket instead:

```bash
docker run -it --rm \
  -e START_DOCKERD=0 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

## Codex Setup

This image installs Codex CLI with:

```bash
npm install -g @openai/codex@latest
```

Do not bake secrets into the image. Pass the API endpoint and API key at runtime:

```bash
docker run -it --rm \
  --privileged \
  -e OPENAI_BASE_URL="http://172.93.108.177:8081" \
  -e OPENAI_API_KEY="YOUR_OPENAI_API_KEY" \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

Inside the container, initialize Codex config:

```bash
init-codex-config
```

The script writes:

```bash
~/.codex/config.toml
~/.codex/auth.json
```

`~/.codex/config.toml`:

```toml
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
```

`~/.codex/auth.json` is generated from `OPENAI_API_KEY`:

```json
{
  "OPENAI_API_KEY": "YOUR_OPENAI_API_KEY"
}
```

Check Codex after initialization:

```bash
codex login status
codex doctor
```

For Tencent Cloud sandbox startup, add these environment variables:

```text
OPENAI_BASE_URL=http://172.93.108.177:8081
OPENAI_API_KEY=YOUR_OPENAI_API_KEY
START_DOCKERD=1
```

Make sure the sandbox/container configuration enables privileged or nested-container mode; otherwise the internal Docker daemon cannot create child containers.

If the platform uses `/init`, keep it as the command and run the Docker startup wrapper as the first argument:

```text
Command: /init
Args:
docker-entrypoint
bash
-lc
init-codex-config && sleep infinity
```

If you enter an existing shell and need to start Docker manually, run:

```bash
docker-entrypoint bash
```

If the platform does not require `/init`, you can initialize Codex during startup with the same wrapper:

```text
Command: docker-entrypoint
Args:
bash
-lc
init-codex-config && sleep infinity
```

If you also mount persistent storage, consider mounting it at `/root/.codex` to keep Codex config across container restarts.

## Push

Push the local image:

```bash
docker push conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

If you use `docker buildx build --push`, the image is pushed during the build step and you do not need to run `docker push` separately.

## Pull

Pull from Tencent Cloud Container Registry:

```bash
docker pull conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

## Host Without Docker

This image cannot run on a host that has no container runtime at all. Install Docker, containerd, or another compatible runtime on the host first.

For Docker-in-container workflows, the recommended setup is:

```bash
docker run --privileged -it --rm \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/swe-sandbox-base:latest
```

This starts Docker inside the container. It still requires the outer host or sandbox platform to allow privileged nested containers.
