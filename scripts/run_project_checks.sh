#!/usr/bin/env sh

set -eu

cfg_file=".template/project-config.yml"
mode="${1:-all}"
target="${2:-}"

if [ ! -f "$cfg_file" ]; then
  echo "No $cfg_file found, skipping project checks."
  exit 0
fi

read_cfg() {
  sh ./scripts/read_project_config.sh "$1"
}

install_cmd="$(read_cfg "commands.install")"
lint_cmd="$(read_cfg "commands.lint")"
test_cmd="$(read_cfg "commands.test")"
build_cmd="$(read_cfg "commands.build")"
run_lint="$(read_cfg "ci.run_lint")"
run_test="$(read_cfg "ci.run_test")"
run_build="$(read_cfg "ci.run_build")"

run_if_set() {
  label="$1"
  cmd="$2"
  if [ -n "$cmd" ]; then
    echo "Running $label: $cmd"
    sh -c "$cmd"
  else
    echo "Skipping $label (not configured)."
  fi
}

enabled_or_default() {
  value="${1:-}"
  fallback="${2:-false}"
  if [ -z "$value" ]; then
    echo "$fallback"
  else
    echo "$value"
  fi
}

case "$mode" in
  install)
    run_if_set "install" "$install_cmd"
    ;;
  lint)
    run_if_set "lint" "$lint_cmd"
    ;;
  test)
    run_if_set "test" "$test_cmd"
    ;;
  build)
    run_if_set "build" "$build_cmd"
    ;;
  enabled)
    case "$target" in
      lint)
        enabled_or_default "$run_lint" "true"
        ;;
      test)
        enabled_or_default "$run_test" "true"
        ;;
      build)
        enabled_or_default "$run_build" "false"
        ;;
      *)
        echo "Unknown target for enabled mode: $target"
        echo "Use one of: lint | test | build"
        exit 1
        ;;
    esac
    ;;
  all)
    run_if_set "install" "$install_cmd"
    if [ "$(enabled_or_default "$run_lint" "true")" = "true" ]; then
      run_if_set "lint" "$lint_cmd"
    else
      echo "Skipping lint (disabled by ci.run_lint)."
    fi
    if [ "$(enabled_or_default "$run_test" "true")" = "true" ]; then
      run_if_set "test" "$test_cmd"
    else
      echo "Skipping test (disabled by ci.run_test)."
    fi
    if [ "$(enabled_or_default "$run_build" "false")" = "true" ]; then
      run_if_set "build" "$build_cmd"
    else
      echo "Skipping build (disabled by ci.run_build)."
    fi
    ;;
  *)
    echo "Unknown mode: $mode"
    echo "Use one of: install | lint | test | build | enabled | all"
    exit 1
    ;;
esac

