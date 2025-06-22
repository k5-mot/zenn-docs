#!/usr/bin/env bash
IFS="," read -r -a DEFAULT_UTILS <<< "${TOOLSTOINSTALL:-git-cz,npm-check-updates,@anthropic-ai/claude-code,@openai/codex}"
set -e

for tool in "${DEFAULT_UTILS[@]}"; do
  echo "Installing $tool..."
  npm install -g "$tool"
done

set +e
echo "Done!"
