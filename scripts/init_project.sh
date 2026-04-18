#!/usr/bin/env sh

set -eu

usage() {
  cat <<'EOF'
Usage:
  ./scripts/init_project.sh <stack> [custom_init_command]

Stacks:
  laravel   Default init: laravel new <tmp_dir>/project
  nextjs    Default init: npx create-next-app@latest <tmp_dir>/project
  flutter   Default init: flutter create <tmp_dir>/project
  python    Default init: none (must provide custom command)
            Custom command must create files in $INIT_TARGET_DIR

Examples:
  ./scripts/init_project.sh laravel
  ./scripts/init_project.sh nextjs
  ./scripts/init_project.sh flutter
  ./scripts/init_project.sh python 'uv init "$INIT_TARGET_DIR"'
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ $# -lt 1 ]; then
  usage
  exit 0
fi

STACK="$1"
shift || true
CUSTOM_CMD="${1:-}"

if [ ! -e ".git" ]; then
  echo "Run this script from the repository root (where .git exists)."
  exit 1
fi

TMP_ROOT="$(mktemp -d)"
INIT_TARGET_DIR="$TMP_ROOT/project"
mkdir -p "$INIT_TARGET_DIR"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT INT TERM

run_default_init() {
  case "$STACK" in
    laravel)
      laravel new "$INIT_TARGET_DIR"
      ;;
    nextjs)
      npx create-next-app@latest "$INIT_TARGET_DIR"
      ;;
    flutter)
      flutter create "$INIT_TARGET_DIR"
      ;;
    python)
      echo "Python requires a custom init command."
      printf '%s\n' 'Example: ./scripts/init_project.sh python '\''uv init "$INIT_TARGET_DIR"'\'''
      exit 1
      ;;
    *)
      echo "Unsupported stack: $STACK"
      echo "Supported: laravel | nextjs | flutter | python"
      exit 1
      ;;
  esac
}

if [ -n "$CUSTOM_CMD" ]; then
  echo "Running custom init command for $STACK..."
  export INIT_TARGET_DIR
  env INIT_TARGET_DIR="$INIT_TARGET_DIR" sh -c "$CUSTOM_CMD"
else
  echo "Running default init command for $STACK..."
  run_default_init
fi

if [ ! -d "$INIT_TARGET_DIR" ]; then
  echo "Init target directory not found: $INIT_TARGET_DIR"
  exit 1
fi

for f in README.md CHANGELOG.md; do
  if [ -f "$INIT_TARGET_DIR/$f" ]; then
    cp -f "$INIT_TARGET_DIR/$f" "./$f"
  fi
done

rsync -a \
  --exclude ".git" \
  --exclude "README.md" \
  --exclude "CHANGELOG.md" \
  --exclude ".github" \
  --exclude ".template" \
  --exclude "scripts" \
  --exclude "templates" \
  --exclude "lefthook.yml" \
  --exclude ".editorconfig" \
  "$INIT_TARGET_DIR"/ ./

if [ -f ".template/repo-settings.yml" ]; then
  case "$STACK" in
    laravel|nextjs|flutter|python)
      sed -i.bak "s/^  stack: .*/  stack: $STACK/" ".template/repo-settings.yml" || true
      rm -f ".template/repo-settings.yml.bak"
      ;;
  esac
fi

echo
echo "Project scaffold merged successfully."
echo "- Framework files were generated safely and merged into root."
echo "- Template governance/workflow files were preserved."
echo "- README.md and CHANGELOG.md from framework take priority."
echo
echo "Next steps:"
echo "1) Review merged files and update .template/repo-settings.yml if needed."
echo "2) Install hooks: lefthook install"
echo "3) Run your framework's install/test commands."
