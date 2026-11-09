#!/bin/sh
# SPDX-FileCopyrightText: 2019 ash contributors <https://github.com/ash-project/ash/graphs/contributors>
#
# SPDX-License-Identifier: MIT

set -eu

# Named volumes are created root-owned.
sudo chown -R vscode:vscode /home/vscode/.claude /home/vscode/.config/gh \
  /home/vscode/.cache/erlang-history

mix deps.get
mix compile
