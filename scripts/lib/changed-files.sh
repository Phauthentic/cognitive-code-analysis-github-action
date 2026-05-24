#!/usr/bin/env bash
set -euo pipefail

resolve_changed_files() {
    local analyze_changed_only="${INPUT_ANALYZE_CHANGED_FILES_ONLY:-true}"
    local paths="${INPUT_PATHS:-src}"

    export CHANGED_FILES=""
    export CHANGED_FILES_COUNT=0

    if [[ "${analyze_changed_only}" == "true" && "${GITHUB_EVENT_NAME:-}" == "pull_request" ]]; then
        local base_sha="${GITHUB_EVENT_PULL_REQUEST_BASE_SHA:-}"

        if [[ -n "${base_sha}" && -n "${GITHUB_BASE_REF:-}" ]]; then
            git fetch origin "${GITHUB_BASE_REF}:${GITHUB_BASE_REF}" 2>/dev/null || true
            CHANGED_FILES=$(git diff --name-only --diff-filter=ACMR "${base_sha}...${GITHUB_SHA}" | grep '\.php$' | tr '\n' ' ' || true)
        fi
    fi

    if [[ -z "${CHANGED_FILES// }" ]]; then
        if [[ "${analyze_changed_only}" == "true" && "${GITHUB_EVENT_NAME:-}" == "pull_request" ]]; then
            echo "No PHP files changed in this pull request."
            return 0
        fi

        CHANGED_FILES="${paths}"
    fi

    if [[ -n "${CHANGED_FILES// }" ]]; then
        CHANGED_FILES_COUNT=$(echo "${CHANGED_FILES}" | wc -w | tr -d ' ')
    fi

    export CHANGED_FILES
    export CHANGED_FILES_COUNT
}
