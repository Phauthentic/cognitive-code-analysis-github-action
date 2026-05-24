#!/usr/bin/env bash
set -euo pipefail

# PR comments, artifacts, and SARIF upload are handled by composite action steps in action.yml.
# This module provides shared helpers for report validation.

report_exists() {
    local file_path="$1"
    [[ -f "${file_path}" && -s "${file_path}" ]]
}
