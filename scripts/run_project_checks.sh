#!/usr/bin/env sh

set -eu

cfg_file=".template/project-config.yml"
mode="${1:-all}"
target="${2:-}"

if [ ! -f ".template/repo-settings.yml" ] && [ ! -f "$cfg_file" ]; then
  echo "No .template/repo-settings.yml or $cfg_file found, skipping project checks."
  exit 0
fi

read_cfg() {
  key="$1"
  default_value="${2:-}"
  sh ./scripts/get_config_value.sh "$key" "$default_value"
}

stack="$(read_cfg "project.stack" "")"
if [ -z "$stack" ]; then
  stack="$(read_cfg "stack" "custom")"
fi

default_command_for_stack() {
  stack_name="$1"
  command_type="$2"
  case "$stack_name" in
    nextjs|js)
      case "$command_type" in
        install) echo "npm ci" ;;
        lint) echo "npm run lint" ;;
        test) echo "npm test" ;;
        build) echo "npm run build" ;;
        *) echo "" ;;
      esac
      ;;
    laravel|php)
      case "$command_type" in
        install) echo "composer install" ;;
        lint) echo "vendor/bin/pint --test" ;;
        test) echo "php artisan test" ;;
        build) echo "" ;;
        *) echo "" ;;
      esac
      ;;
    flutter)
      case "$command_type" in
        install) echo "flutter pub get" ;;
        lint) echo "flutter analyze" ;;
        test) echo "flutter test" ;;
        build) echo "flutter build apk" ;;
        *) echo "" ;;
      esac
      ;;
    python)
      case "$command_type" in
        install) echo "pip install -r requirements.txt" ;;
        lint) echo "ruff check ." ;;
        test) echo "pytest -q" ;;
        build) echo "" ;;
        *) echo "" ;;
      esac
      ;;
    *)
      echo ""
      ;;
  esac
}

resolve_command() {
  configured_cmd="$1"
  stack_name="$2"
  command_type="$3"
  if [ -n "$configured_cmd" ]; then
    echo "$configured_cmd"
  else
    default_command_for_stack "$stack_name" "$command_type"
  fi
}

install_cmd="$(resolve_command "$(read_cfg "commands.install" "")" "$stack" "install")"
lint_cmd="$(resolve_command "$(read_cfg "commands.lint" "")" "$stack" "lint")"
test_cmd="$(resolve_command "$(read_cfg "commands.test" "")" "$stack" "test")"
build_cmd="$(resolve_command "$(read_cfg "commands.build" "")" "$stack" "build")"
run_lint="$(read_cfg "ci.run_lint" "true")"
run_test="$(read_cfg "ci.run_test" "true")"
run_build="$(read_cfg "ci.run_build" "false")"

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
