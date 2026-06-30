# Python Base Development Image

Sandbox-compatible Linux + Python development image for Tencent Cloud Container Registry.

Image:

```bash
conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

## What's Included

- Base image: `ccr.ccs.tencentyun.com/ags-image/sandbox-code:latest`
- Keeps the sandbox / E2B-compatible data plane capabilities from the base image
- Debian bookworm Linux base
- Python 3.12
- pip, uv, virtualenv, aiohttp
- Docker CLI, docker buildx, docker compose plugin
- git, curl, wget, openssh-client
- build-essential, gcc, g++, make
- pytest, pytest-cov, ruff, black, mypy, ipython, debugpy
- vim, nano, jq, htop, tree, unzip, zip, sudo

Note: this image extends Tencent Cloud's `sandbox-code` base image, so it is a better fit for sandbox / code-interpreter style platforms than a plain Debian or Python image.

Note: this image includes Docker client tools, not a Docker daemon. To run Docker commands inside this container, the host machine must have Docker installed and expose `/var/run/docker.sock` to the container.

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
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest \
  .
```

If your platform requires pushing at build time, use:

```bash
docker buildx build \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest \
  --push \
  .
```

Build for Apple Silicon / ARM64:

```bash
docker buildx build --platform linux/arm64 \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest \
  .
```

Build for common x86 Linux servers:

```bash
docker buildx build --platform linux/amd64 \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest \
  .
```

Build and push a multi-architecture image for both x86 Linux servers and Apple Silicon:

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest \
  --push \
  .
```

## Run

Run an interactive shell:

```bash
docker run -it --rm \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

This image defaults to:

```bash
bash
```

Run with the current project mounted to `/workspace`:

```bash
docker run -it --rm \
  -v "$PWD":/workspace \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

Run with host Docker access:

```bash
docker run -it --rm \
  -v "$PWD":/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

After entering the container, verify tools:

```bash
python --version
pip --version
uv --version
docker --version
docker buildx version
docker compose version
```

## Push

Push the local image:

```bash
docker push conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

If you use `docker buildx build --push`, the image is pushed during the build step and you do not need to run `docker push` separately.

## Pull

Pull from Tencent Cloud Container Registry:

```bash
docker pull conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

## Host Without Docker

This image cannot run on a host that has no container runtime at all. Install Docker, containerd, or another compatible runtime on the host first.

For Docker-in-container workflows, the recommended setup is:

```bash
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  conductor-artifacts.tencentcloudcr.com/deploy-artifacts/pythonbase:latest
```

This lets the container use the host Docker daemon through the Docker socket.
