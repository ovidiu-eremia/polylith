FROM ubuntu:24.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GNAME=$USERNAME
ARG USER_GID=$USER_UID

RUN userdel -f -r ubuntu \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && groupadd --system --force systemd-journal || true \
    && id -u systemd-network &>/dev/null || useradd --system --no-create-home systemd-network \
    && apt update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
        systemd \
        policykit-1 \
        dbus \
        coreutils \
        procps \
        openjdk-17-jdk \
        unixodbc \
        unixodbc-dev \
        bash \
        sudo \
        bash-completion \
        iproute2 \
        tmux \
        acl \
        zsh \
        curl \
        zip \
        gzip \
        unzip \
        less \
        xz-utils \
        apt-utils \
        vim-tiny \
        gpg-agent \
        ca-certificates \
        software-properties-common \
    && systemd-sysusers \
    && mkdir -p /run/dbus \
    && dbus-daemon --system \
    && install -m 0755 -d /etc/apt/keyrings \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && apt-get autoremove -y \
    && apt-get clean \
    && apt clean \
    && rm -rf ~/.curlrc \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:git-core/ppa \
    && apt update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends \
        pipx \
        git \
    && apt upgrade pipx \
    && pipx ensurepath \
    && apt-get autoremove -y \
    && apt-get clean \
    && apt clean \
    && rm -rfd /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ${USERNAME}

RUN (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt upgrade -y \
    && sudo apt install gh -y \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean \
    && sudo apt clean \
    && rm -rf ~/.curlrc \
    && sudo rm -rfd /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
RUN cd $HOME \
    && curl -fsSL --proto "=https" https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh \
    && curl -LsSf --proto "=https" https://astral.sh/uv/install.sh | sh \
    && sudo curl --proto "=https" --location --remote-name https://github.com/brettcannon/python-launcher/releases/download/v1.0.1/python_launcher-1.0.1-x86_64-unknown-linux-gnu.tar.xz \
    && sudo chmod +r python_launcher-1.0.1-x86_64-unknown-linux-gnu.tar.xz \
    && sudo tar --extract --strip-components 1 --directory /usr/local --file python_launcher-1.0.1-x86_64-unknown-linux-gnu.tar.xz \
    && sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && sudo rm -rf /opt/nvim* \
    && sudo chmod +r nvim-linux-x86_64.tar.gz \
    && sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && rm -rf python_launcher-1.0.1-x86_64-unknown-linux-gnu.tar.xz \
    && rm -rf nvim-linux-x86_64.tar.gz

RUN echo 'eval "$(register-python-argcomplete3 pipx)"' >> ~/.bashrc \
    && echo 'export PIPX_DEFAULT_PYTHON=python${PYTHON_VERSION}' >> ~/.bashrc \
    && echo 'export PY_PYTHON=${PYTHON_VERSION}' >> ~/.bashrc \
    && mkdir -p ~/.local/share/bash-completion/completions \
    && sudo bash -c "databricks completion bash > /etc/bash_completion.d/databricks" \
    && echo 'eval "$(gh completion -s bash)"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.profile

CMD ["tail", "-f", "/dev/null"]
# ENTRYPOINT [ "/bin/bash", "-l"]
# CMD is used here instead of ENTRYPOINT to allow users to override the default command if needed.
