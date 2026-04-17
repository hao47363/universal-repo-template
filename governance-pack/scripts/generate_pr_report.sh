#!/usr/bin/env sh

set -eu

OUTPUT_FILE="${1:-pr-report.md}"

read_cfg() {
  key="$1"
  default_value="${2:-}"
  sh ./governance-pack/scripts/get_config_value.sh "$key" "$default_value"
}

enabled="$(read_cfg "pr_intelligence.enabled" "true")"
strict_mode="$(read_cfg "pr_intelligence.strict_mode" "false")"
hotspot_history_commits="$(read_cfg "pr_intelligence.hotspot_history_commits" "200")"
hotspot_threshold="$(read_cfg "pr_intelligence.hotspot_threshold" "6")"
ignore_patterns="$(read_cfg "pr_intelligence.ignore_patterns" "")"

if [ "$enabled" != "true" ]; then
  {
    echo "# PR Intelligence Report"
    echo
    echo "PR Intelligence is disabled by \`pr_intelligence.enabled=false\`."
  } > "$OUTPUT_FILE"
  exit 0
fi

base_ref="${PR_BASE_REF:-${GITHUB_BASE_REF:-}}"
head_sha="${PR_HEAD_SHA:-${GITHUB_SHA:-HEAD}}"

if [ -z "$base_ref" ]; then
  base_ref="${2:-main}"
fi

git fetch --no-tags origin "$base_ref":"refs/remotes/origin/$base_ref" >/dev/null 2>&1 || true

if git show-ref --verify --quiet "refs/remotes/origin/$base_ref"; then
  base_target="refs/remotes/origin/$base_ref"
else
  base_target="$base_ref"
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

name_status_file="$tmp_dir/name_status.txt"
numstat_file="$tmp_dir/numstat.txt"
meaningful_paths_file="$tmp_dir/meaningful_paths.txt"
api_file="$tmp_dir/api.txt"
backend_file="$tmp_dir/backend.txt"
database_file="$tmp_dir/database.txt"
ui_file="$tmp_dir/ui.txt"
config_file="$tmp_dir/config.txt"
hotspots_file="$tmp_dir/hotspots.txt"

range="$base_target...$head_sha"

if ! git rev-parse --verify "$head_sha" >/dev/null 2>&1; then
  echo "Unable to resolve head SHA/ref: $head_sha" >&2
  [ "$strict_mode" = "true" ] && exit 1
  head_sha="HEAD"
  range="$base_target...$head_sha"
fi

if ! git diff --name-status -M --diff-filter=ACDMRTUXB "$range" > "$name_status_file" 2>/dev/null; then
  echo "Unable to generate name-status diff for range: $range" >&2
  [ "$strict_mode" = "true" ] && exit 1
  : > "$name_status_file"
fi

if ! git diff --numstat -M --diff-filter=ACDMRTUXB "$range" > "$numstat_file" 2>/dev/null; then
  echo "Unable to generate numstat diff for range: $range" >&2
  [ "$strict_mode" = "true" ] && exit 1
  : > "$numstat_file"
fi

is_ignored_file() {
  file_path="$1"
  case "$file_path" in
    *.lock|*package-lock.json|*pnpm-lock.yaml|*yarn.lock|*composer.lock|*poetry.lock|*Pipfile.lock|*Cargo.lock|*Gemfile.lock)
      return 0
      ;;
    *.min.js|*.min.css|*.map)
      return 0
      ;;
    dist/*|build/*|coverage/*|tmp/*|temp/*|vendor/*|node_modules/*|.next/*|out/*|target/*|bin/*|obj/*)
      return 0
      ;;
    *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.pdf)
      return 0
      ;;
  esac

  old_ifs="$IFS"
  IFS=','
  for pattern in $ignore_patterns; do
    trimmed="$(printf '%s' "$pattern" | awk '{$1=$1};1')"
    [ -z "$trimmed" ] && continue
    case "$file_path" in
      $trimmed) IFS="$old_ifs"; return 0 ;;
    esac
  done
  IFS="$old_ifs"

  return 1
}

extract_path_from_name_status() {
  line="$1"
  status="$(printf '%s\n' "$line" | awk '{print $1}')"
  case "$status" in
    R*|C*)
      printf '%s\n' "$line" | awk '{print $NF}'
      ;;
    *)
      printf '%s\n' "$line" | awk '{print $2}'
      ;;
  esac
}

: > "$meaningful_paths_file"
: > "$api_file"
: > "$backend_file"
: > "$database_file"
: > "$ui_file"
: > "$config_file"
: > "$hotspots_file"

rename_count=0
delete_count=0
files_changed_all=0

while IFS= read -r line; do
  [ -z "$line" ] && continue
  files_changed_all=$((files_changed_all + 1))
  status="$(printf '%s\n' "$line" | awk '{print $1}')"
  case "$status" in
    R*) rename_count=$((rename_count + 1)) ;;
    D) delete_count=$((delete_count + 1)) ;;
  esac

  path="$(extract_path_from_name_status "$line")"
  [ -z "$path" ] && continue
  if is_ignored_file "$path"; then
    continue
  fi
  printf '%s\n' "$path" >> "$meaningful_paths_file"
done < "$name_status_file"

sort -u "$meaningful_paths_file" -o "$meaningful_paths_file"

files_changed="$(wc -l < "$meaningful_paths_file" | tr -d ' ')"
lines_added=0
lines_deleted=0

while IFS= read -r line; do
  [ -z "$line" ] && continue
  added="$(printf '%s\n' "$line" | awk '{print $1}')"
  deleted="$(printf '%s\n' "$line" | awk '{print $2}')"
  file_path="$(printf '%s\n' "$line" | awk '{print $3}')"
  [ -z "$file_path" ] && continue
  if is_ignored_file "$file_path"; then
    continue
  fi

  case "$added" in
    ''|*[!0-9]*) added=0 ;;
  esac
  case "$deleted" in
    ''|*[!0-9]*) deleted=0 ;;
  esac

  lines_added=$((lines_added + added))
  lines_deleted=$((lines_deleted + deleted))
done < "$numstat_file"

line_churn=$((lines_added + lines_deleted))

critical_path_hits=0
config_dep_hits=0
auth_payment_hits=0

while IFS= read -r path; do
  [ -z "$path" ] && continue
  top_dir="$(printf '%s\n' "$path" | awk -F/ '{print $1}')"
  printf '%s\n' "$top_dir"
done < "$meaningful_paths_file" | sort -u > "$tmp_dir/top_dirs.txt"
cross_module_count="$(wc -l < "$tmp_dir/top_dirs.txt" | tr -d ' ')"

while IFS= read -r path; do
  [ -z "$path" ] && continue

  case "$path" in
    *api*|*routes*|*controller*|*endpoint*|openapi*|swagger*)
      printf '%s\n' "$path" >> "$api_file"
      ;;
  esac
  case "$path" in
    *src/*|*service*|*domain*|*core*|*handler*|*logic*|*module*)
      printf '%s\n' "$path" >> "$backend_file"
      ;;
  esac
  case "$path" in
    *migrations/*|*migration*|*schema*|*database*|*db/*|*.sql)
      printf '%s\n' "$path" >> "$database_file"
      ;;
  esac
  case "$path" in
    *ui/*|*frontend/*|*components/*|*pages/*|*views/*|*.tsx|*.jsx|*.css|*.scss|*.vue|*.svelte)
      printf '%s\n' "$path" >> "$ui_file"
      ;;
  esac
  case "$path" in
    *.yml|*.yaml|*.toml|*.ini|*.env|*.json|Dockerfile*|docker-compose*|*.properties|Makefile|*.mk|*.tf|*.hcl|*.xml|*.conf)
      printf '%s\n' "$path" >> "$config_file"
      config_dep_hits=$((config_dep_hits + 1))
      ;;
  esac

  case "$path" in
    *auth*|*payment*|*billing*|*secret*|*token*|*.env*|*security*)
      critical_path_hits=$((critical_path_hits + 1))
      auth_payment_hits=$((auth_payment_hits + 1))
      ;;
  esac
  case "$path" in
    *config*|*.github/*|*settings*|*workflow*|*pipeline*)
      critical_path_hits=$((critical_path_hits + 1))
      ;;
  esac

  case "$path" in
    *requirements.txt|*pyproject.toml|*package.json|*composer.json|*go.mod|*Cargo.toml|*pubspec.yaml)
      config_dep_hits=$((config_dep_hits + 1))
      ;;
  esac
done < "$meaningful_paths_file"

sort -u "$api_file" -o "$api_file"
sort -u "$backend_file" -o "$backend_file"
sort -u "$database_file" -o "$database_file"
sort -u "$ui_file" -o "$ui_file"
sort -u "$config_file" -o "$config_file"

risk_score=0
risk_reasons_file="$tmp_dir/risk_reasons.txt"
: > "$risk_reasons_file"

if [ "$files_changed" -ge 60 ]; then
  risk_score=$((risk_score + 3))
  printf '%s\n' "- High file count: ${files_changed} meaningful files changed (+3)." >> "$risk_reasons_file"
elif [ "$files_changed" -ge 20 ]; then
  risk_score=$((risk_score + 2))
  printf '%s\n' "- Medium file count: ${files_changed} meaningful files changed (+2)." >> "$risk_reasons_file"
elif [ "$files_changed" -ge 8 ]; then
  risk_score=$((risk_score + 1))
  printf '%s\n' "- Elevated file count: ${files_changed} meaningful files changed (+1)." >> "$risk_reasons_file"
fi

if [ "$line_churn" -ge 2000 ]; then
  risk_score=$((risk_score + 3))
  printf '%s\n' "- Very high line churn: ${line_churn} changed lines (+3)." >> "$risk_reasons_file"
elif [ "$line_churn" -ge 600 ]; then
  risk_score=$((risk_score + 2))
  printf '%s\n' "- High line churn: ${line_churn} changed lines (+2)." >> "$risk_reasons_file"
elif [ "$line_churn" -ge 150 ]; then
  risk_score=$((risk_score + 1))
  printf '%s\n' "- Moderate line churn: ${line_churn} changed lines (+1)." >> "$risk_reasons_file"
fi

if [ "$cross_module_count" -ge 6 ]; then
  risk_score=$((risk_score + 2))
  printf '%s\n' "- Cross-module spread: ${cross_module_count} top-level directories affected (+2)." >> "$risk_reasons_file"
elif [ "$cross_module_count" -ge 3 ]; then
  risk_score=$((risk_score + 1))
  printf '%s\n' "- Multi-module spread: ${cross_module_count} top-level directories affected (+1)." >> "$risk_reasons_file"
fi

if [ "$critical_path_hits" -ge 5 ]; then
  risk_score=$((risk_score + 2))
  printf '%s\n' "- Critical path indicators: ${critical_path_hits} auth/payment/config/security related files (+2)." >> "$risk_reasons_file"
elif [ "$critical_path_hits" -ge 1 ]; then
  risk_score=$((risk_score + 1))
  printf '%s\n' "- Critical path touch: ${critical_path_hits} auth/payment/config/security related files (+1)." >> "$risk_reasons_file"
fi

if [ "$rename_count" -ge 10 ] || [ "$delete_count" -ge 10 ]; then
  risk_score=$((risk_score + 1))
  printf '%s\n' "- Structural churn: ${rename_count} renames, ${delete_count} deletes (+1)." >> "$risk_reasons_file"
fi

if [ "$risk_score" -gt 10 ]; then
  risk_score=10
fi

large_refactor="false"
if [ "$files_changed" -ge 40 ] || [ "$rename_count" -ge 10 ] || [ "$delete_count" -ge 10 ]; then
  large_refactor="true"
fi

large_refactor_severity="LOW"
if [ "$large_refactor" = "true" ]; then
  if [ "$files_changed" -ge 90 ] || [ "$line_churn" -ge 3000 ]; then
    large_refactor_severity="CRITICAL"
  elif [ "$files_changed" -ge 60 ] || [ "$line_churn" -ge 1800 ]; then
    large_refactor_severity="HIGH"
  else
    large_refactor_severity="MEDIUM"
  fi
fi

hotspot_level="LOW"
max_hotspot_count=0
if [ "$files_changed" -gt 0 ]; then
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    touch_count="$(git log --no-merges --pretty=format:%H -n "$hotspot_history_commits" "$base_target" -- "$path" | wc -l | tr -d ' ')"
    case "$touch_count" in
      ''|*[!0-9]*) touch_count=0 ;;
    esac
    if [ "$touch_count" -gt "$max_hotspot_count" ]; then
      max_hotspot_count="$touch_count"
    fi
    if [ "$touch_count" -ge "$hotspot_threshold" ]; then
      printf '%s (%s prior touches)\n' "$path" "$touch_count" >> "$hotspots_file"
    fi
  done < "$meaningful_paths_file"
fi

sort -u "$hotspots_file" -o "$hotspots_file"

if [ -s "$hotspots_file" ]; then
  if [ "$max_hotspot_count" -ge $((hotspot_threshold + 8)) ]; then
    hotspot_level="CRITICAL"
  elif [ "$max_hotspot_count" -ge $((hotspot_threshold + 5)) ]; then
    hotspot_level="HIGH"
  else
    hotspot_level="MEDIUM"
  fi
fi

config_dep_level="LOW"
if [ "$config_dep_hits" -ge 10 ]; then
  config_dep_level="CRITICAL"
elif [ "$config_dep_hits" -ge 5 ]; then
  config_dep_level="HIGH"
elif [ "$config_dep_hits" -ge 2 ]; then
  config_dep_level="MEDIUM"
fi

api_count="$(wc -l < "$api_file" | tr -d ' ')"
backend_count="$(wc -l < "$backend_file" | tr -d ' ')"
database_count="$(wc -l < "$database_file" | tr -d ' ')"
ui_count="$(wc -l < "$ui_file" | tr -d ' ')"
config_count="$(wc -l < "$config_file" | tr -d ' ')"

impact_areas_file="$tmp_dir/impact_areas.txt"
: > "$impact_areas_file"
[ "$api_count" -gt 0 ] && echo "API" >> "$impact_areas_file"
[ "$backend_count" -gt 0 ] && echo "Backend logic" >> "$impact_areas_file"
[ "$database_count" -gt 0 ] && echo "Database" >> "$impact_areas_file"
[ "$ui_count" -gt 0 ] && echo "UI" >> "$impact_areas_file"
[ "$config_count" -gt 0 ] && echo "Configuration" >> "$impact_areas_file"
impact_area_count="$(wc -l < "$impact_areas_file" | tr -d ' ')"
impact_areas_csv="$(paste -sd ', ' "$impact_areas_file" 2>/dev/null || true)"
[ -z "$impact_areas_csv" ] && impact_areas_csv="None"

score_to_level() {
  score="$1"
  if [ "$score" -ge 9 ]; then
    echo "CRITICAL"
  elif [ "$score" -ge 7 ]; then
    echo "HIGH"
  elif [ "$score" -ge 4 ]; then
    echo "MEDIUM"
  else
    echo "LOW"
  fi
}

severity_rank() {
  case "$1" in
    LOW) echo 1 ;;
    MEDIUM) echo 2 ;;
    HIGH) echo 3 ;;
    CRITICAL) echo 4 ;;
    *) echo 0 ;;
  esac
}

max_severity() {
  current="$1"
  candidate="$2"
  if [ "$(severity_rank "$candidate")" -gt "$(severity_rank "$current")" ]; then
    echo "$candidate"
  else
    echo "$current"
  fi
}

overall_risk_level="$(score_to_level "$risk_score")"
overall_risk_level="$(max_severity "$overall_risk_level" "$hotspot_level")"
overall_risk_level="$(max_severity "$overall_risk_level" "$config_dep_level")"
if [ "$large_refactor" = "true" ]; then
  overall_risk_level="$(max_severity "$overall_risk_level" "$large_refactor_severity")"
fi

summary_points_file="$tmp_dir/summary_points.txt"
: > "$summary_points_file"
if [ "$impact_area_count" -gt 0 ]; then
  echo "Impacts ${impact_area_count} area(s): ${impact_areas_csv}." >> "$summary_points_file"
else
  echo "No high-signal impact area was detected from path rules." >> "$summary_points_file"
fi
if [ "$large_refactor" = "true" ]; then
  echo "Refactor pattern detected at ${large_refactor_severity} severity." >> "$summary_points_file"
fi
if [ -s "$hotspots_file" ]; then
  echo "Hotspot files are present (${hotspot_level})." >> "$summary_points_file"
fi
if [ "$config_dep_hits" -gt 0 ]; then
  echo "Configuration/dependency touch count is ${config_dep_hits} (${config_dep_level})." >> "$summary_points_file"
fi
if [ "$critical_path_hits" -gt 0 ]; then
  echo "Critical path signal count is ${critical_path_hits} (auth/payment/config/security)." >> "$summary_points_file"
fi

review_recommendation="Normal review path is sufficient."
case "$overall_risk_level" in
  CRITICAL)
    review_recommendation="Require full reviewer sweep across impacted modules before merge."
    ;;
  HIGH)
    review_recommendation="Require at least one domain-owner review for impacted critical areas."
    ;;
  MEDIUM)
    review_recommendation="Prioritize targeted review on impacted areas and config changes."
    ;;
esac

render_list_or_none() {
  file="$1"
  if [ -s "$file" ]; then
    while IFS= read -r path; do
      [ -z "$path" ] && continue
      printf -- '- `%s`\n' "$path"
    done < "$file"
  else
    echo "- None"
  fi
}

{
  echo "# PR Intelligence Report"
  echo
  echo "Comparison range: \`$range\`"
  echo
  echo "## Executive Summary"
  echo
  echo "- Overall risk level: **$overall_risk_level**"
  echo "- Risk score basis: **$risk_score/10**"
  echo "- Impacted areas: **$impact_areas_csv**"
  echo "- Reviewer recommendation: $review_recommendation"
  if [ -s "$summary_points_file" ]; then
    while IFS= read -r point; do
      [ -z "$point" ] && continue
      echo "- $point"
    done < "$summary_points_file"
  fi
  echo
  echo "## 1. PR Risk Score"
  echo
  echo "- Score: **$risk_score/10**"
  echo "- Meaningful files changed: **$files_changed**"
  echo "- Line churn (added + deleted): **$line_churn** (${lines_added} + ${lines_deleted})"
  echo "- Renames: **$rename_count**, Deletes: **$delete_count**"
  echo "- Cross-module spread: **$cross_module_count** top-level directories"
  echo
  echo "### Reasons"
  if [ -s "$risk_reasons_file" ]; then
    cat "$risk_reasons_file"
  else
    echo "- No elevated risk signals were triggered."
  fi
  echo
  echo "## 2. Impact Analysis"
  echo
  echo "### API"
  render_list_or_none "$api_file"
  echo
  echo "### Backend logic"
  render_list_or_none "$backend_file"
  echo
  echo "### Database"
  render_list_or_none "$database_file"
  echo
  echo "### UI"
  render_list_or_none "$ui_file"
  echo
  echo "### Configuration"
  render_list_or_none "$config_file"
  echo
  echo "## 3. PR Pattern Detection"
  echo
  if [ "$large_refactor" = "true" ]; then
    echo "- Large refactor: **$large_refactor_severity**"
    echo "  - Signals: files_changed=${files_changed}, renames=${rename_count}, deletes=${delete_count}, line_churn=${line_churn}"
  else
    echo "- Large refactor: **LOW**"
    echo "  - Signals below refactor thresholds."
  fi
  echo
  if [ -s "$hotspots_file" ]; then
    echo "- Hotspot files: **$hotspot_level**"
    render_list_or_none "$hotspots_file"
  else
    echo "- Hotspot files: **LOW**"
    echo "- None crossed hotspot threshold (${hotspot_threshold} prior touches in last ${hotspot_history_commits} commits)."
  fi
  echo
  echo "- Configuration or dependency changes: **$config_dep_level**"
  echo "  - Detected ${config_dep_hits} config/dependency-related file signals."
  echo
  echo "## Determinism & Scope Notes"
  echo
  echo "- Report is regenerated from scratch on every run (stateless overwrite)."
  echo "- Conclusions are derived from git diff, file statuses, and file paths only."
  echo "- Merge commits are excluded from hotspot history (\`--no-merges\`)."
  echo "- Generated/non-meaningful files are filtered by deterministic ignore rules."
  echo "- Auth/payment path signal count: ${auth_payment_hits}."
} > "$OUTPUT_FILE"
