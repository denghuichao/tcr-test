FROM ccr.ccs.tencentyun.com/ags-image/sandbox-code:latest

LABEL org.opencontainers.image.title="swe-sandbox-base"
LABEL org.opencontainers.image.description="Sandbox-compatible Linux and Python development environment"

ARG DEBIAN_FRONTEND=noninteractive
ARG PIP_INDEX_URL=https://mirrors.cloud.tencent.com/pypi/simple

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Shanghai \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_INDEX_URL=${PIP_INDEX_URL}

RUN set -eux; \
    if command -v apt-get >/dev/null 2>&1; then \
        if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
            sed -i \
                -e 's|http://deb.debian.org/debian-security|https://mirrors.tencent.com/debian-security|g' \
                -e 's|http://deb.debian.org/debian|https://mirrors.tencent.com/debian|g' \
                -e 's|http://security.debian.org/debian-security|https://mirrors.tencent.com/debian-security|g' \
                /etc/apt/sources.list.d/debian.sources; \
        fi; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            bash \
            bash-completion \
            build-essential \
            ca-certificates \
            curl \
            git \
            gnupg \
            htop \
            iproute2 \
            iputils-ping \
            jq \
            less \
            locales \
            make \
            nano \
            net-tools \
            nodejs \
            openssh-client \
            procps \
            python3 \
            python3-dev \
            python3-pip \
            python3-venv \
            sudo \
            tini \
            tree \
            tzdata \
            unzip \
            vim \
            wget \
            zip; \
        install -m 0755 -d /etc/apt/keyrings; \
        curl -fsSL https://mirrors.tencent.com/docker-ce/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
        chmod a+r /etc/apt/keyrings/docker.gpg; \
        . /etc/os-release; \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tencent.com/docker-ce/linux/debian ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            docker-buildx-plugin \
            docker-ce-cli \
            docker-compose-plugin; \
        ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime; \
        echo "${TZ}" > /etc/timezone; \
        apt-get clean; \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Unsupported base image: apt-get not found" >&2; \
        exit 1; \
    fi; \
    if ! command -v python >/dev/null 2>&1; then ln -sf "$(command -v python3)" /usr/local/bin/python; fi; \
    if ! command -v pip >/dev/null 2>&1; then ln -sf "$(command -v pip3)" /usr/local/bin/pip; fi; \
    python -m pip install --upgrade pip setuptools wheel; \
    python -m pip install \
        aiohttp \
        black \
        debugpy \
        ipython \
        mypy \
        pytest \
        pytest-cov \
        ruff \
        uv \
        virtualenv; \
    npm install -g @openai/codex@latest; \
    npm cache clean --force; \
    codex --version

COPY scripts/init-codex-config.sh /usr/local/bin/init-codex-config

RUN chmod +x /usr/local/bin/init-codex-config

WORKDIR /workspace

CMD ["bash"]
