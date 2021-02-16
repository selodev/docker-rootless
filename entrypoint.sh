#!/bin/bash
set -ea

/home/coder/.local/bin/code-server --user-data-dir /home/coder/.config \
			--extensions-dir /home/coder/.config/extensions
