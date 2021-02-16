#!/bin/bash
set -ea

dumb-init /home/coder/.local/bin/code-server --user-data-dir /home/coder/.config \
			--extensions-dir /home/coder/.config/extensions
