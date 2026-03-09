#!/bin/sh
set -eu

REPO_DIR="/config"

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed in the Home Assistant container" >&2
  exit 127
fi

cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: /config is not a git repository" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "ERROR: Missing git remote 'origin'" >&2
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
  echo "ERROR: Unable to determine git branch" >&2
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "No changes detected"
  exit 0
fi

git commit -m "Auto backup: $(date '+%Y-%m-%dT%H:%M:%S%z')"
git pull --rebase origin "$BRANCH"
git push origin "$BRANCH"