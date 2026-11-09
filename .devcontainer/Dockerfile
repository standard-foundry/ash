# SPDX-FileCopyrightText: 2019 ash contributors <https://github.com/ash-project/ash/graphs/contributors>
#
# SPDX-License-Identifier: MIT

# Development image for working on Ash itself. Ash's own test suite uses the ETS and Mnesia data
# layers, so no database service is needed.
#
# Keep ELIXIR_VERSION and OTP_VERSION equal to .tool-versions, which CI installs from.
# https://hub.docker.com/r/hexpm/elixir/tags
ARG ELIXIR_VERSION=1.20.0
ARG OTP_VERSION=29.0
ARG DEBIAN_VERSION=trixie-20260610-slim

FROM docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}

# build-essential compiles the picosat_elixir NIF. pipx runs `reuse lint` from `mix check`.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    fzf \
    git \
    gnupg2 \
    inotify-tools \
    jq \
    less \
    man-db \
    openssh-client \
    pipx \
    procps \
    sudo \
    unzip \
    vim \
    wget \
    zsh \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
    wget -q "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" && \
    dpkg -i "git-delta_${DELTA_VERSION}_${ARCH}.deb" && \
    rm "git-delta_${DELTA_VERSION}_${ARCH}.deb"

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# The bind mount can fake inode and ownership fields. `checkStat minimal` stops spurious "local
# changes would be overwritten" aborts, and `safe.directory` stops "dubious ownership" errors.
# Both stay in the system scope so the Dev Containers extension still copies the host gitconfig.
RUN git config --system core.checkStat minimal \
    && git config --system --add safe.directory /workspace

USER $USERNAME

ENV ERL_AFLAGS="-kernel shell_history enabled"

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/gusaiani/elixir-oh-my-zsh.git /home/${USERNAME}/.oh-my-zsh/custom/plugins/elixir \
    && sed -i 's/plugins=(git)/plugins=(git elixir)/' /home/${USERNAME}/.zshrc

# The zsh history shares the persisted IEx history volume.
RUN mkdir -p /home/${USERNAME}/.cache/erlang-history \
    && cat >> "/home/${USERNAME}/.zshrc" <<'EOF'
export HISTFILE="$HOME/.cache/erlang-history/.zsh_history"
export PATH="$HOME/.local/bin:$PATH"
EOF

RUN curl -fsSL https://claude.ai/install.sh | bash

# Debian's pipx is older than the version .tool-versions pins. This copy lands first on PATH.
ARG PIPX_VERSION=1.8.0
RUN pipx install "pipx==${PIPX_VERSION}"

RUN mkdir -p /home/${USERNAME}/.claude /home/${USERNAME}/.config/gh

ENV CLAUDE_CONFIG_DIR="/home/${USERNAME}/.claude" \
    DEVCONTAINER="true"

RUN mix local.hex --force && mix local.rebar --force

# The get-started tutorial generates projects with `mix igniter.new` (and `--with phx.new`), and
# the how-to guides are Livebook notebooks. Run `livebook server` and open the forwarded port.
# https://hex.pm/packages/igniter_new https://hex.pm/packages/phx_new https://hex.pm/packages/livebook
ARG IGNITER_NEW_VERSION=0.5.35
ARG PHX_NEW_VERSION=1.8.16
ARG LIVEBOOK_VERSION=0.19.10
RUN mix archive.install hex igniter_new ${IGNITER_NEW_VERSION} --force \
    && mix archive.install hex phx_new ${PHX_NEW_VERSION} --force \
    && mix escript.install hex livebook ${LIVEBOOK_VERSION} --force

ENV PATH="/home/${USERNAME}/.mix/escripts:${PATH}"

WORKDIR /workspace
